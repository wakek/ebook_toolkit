import 'dart:async';
import 'dart:convert' as convert;

import 'package:archive/archive.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_metadata.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_doc_author.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_doc_title.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_head.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_head_meta.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_label.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_list.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_map.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_page_list.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_page_target.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_page_target_type.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_point.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_target.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_manifest_item.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_package.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_version.dart';
import 'package:ebook_toolkit/src/utils/zip_path_utils.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart' as xml;

class NavigationReader {
  static String? _tocFileEntryPath;

  Future<EpubNavigation> readNavigation(
    Archive epubArchive,
    String contentDirectoryPath,
    EpubPackage package,
  ) async {
    var result = const EpubNavigation(
      docAuthors: <EpubNavigationDocAuthor>[],
      navLists: <EpubNavigationList>[],
    );

    if (package.version == EpubVersion.epub2) {
      final tocId = package.spine!.tableOfContents;
      if (tocId == null || tocId.isEmpty) {
        throw Exception('EPUB parsing error: TOC ID is empty.');
      }

      final tocManifestItem = package.manifest!.items!
          .cast<EpubManifestItem?>()
          .firstWhere(
            (EpubManifestItem? item) =>
                item!.id!.toLowerCase() == tocId.toLowerCase(),
            orElse: () => null,
          );
      if (tocManifestItem == null) {
        throw Exception(
          'EPUB parsing error: TOC item $tocId not found in EPUB manifest.',
        );
      }

      _tocFileEntryPath = ZipPathUtils.combine(
        contentDirectoryPath,
        tocManifestItem.href,
      );
      final tocFileEntry = epubArchive.files.cast<ArchiveFile?>().firstWhere(
        (ArchiveFile? file) =>
            file!.name.toLowerCase() == _tocFileEntryPath!.toLowerCase(),
        orElse: () => null,
      );
      if (tocFileEntry == null) {
        throw Exception(
          'EPUB parsing error: TOC file $_tocFileEntryPath not found in archive.',
        );
      }

      final containerDocument = xml.XmlDocument.parse(
        convert.utf8.decode(tocFileEntry.content as List<int>? ?? []),
      );

      const ncxNamespace = 'http://www.daisy.org/z3986/2005/ncx/';
      final ncxNode = containerDocument
          .findAllElements('ncx', namespace: ncxNamespace)
          .cast<xml.XmlElement?>()
          .firstWhere(
            (xml.XmlElement? elem) => elem != null,
            orElse: () => null,
          );
      if (ncxNode == null) {
        throw Exception(
          'EPUB parsing error: TOC file does not contain ncx element.',
        );
      }

      final headNode = ncxNode
          .findAllElements('head', namespace: ncxNamespace)
          .cast<xml.XmlElement?>()
          .firstWhere(
            (xml.XmlElement? elem) => elem != null,
            orElse: () => null,
          );
      if (headNode == null) {
        throw Exception(
          'EPUB parsing error: TOC file does not contain head element.',
        );
      }

      final navigationHead = readNavigationHead(headNode);

      result = result.copyWith(
        head: navigationHead,
      );

      final docTitleNode = ncxNode
          .findElements('docTitle', namespace: ncxNamespace)
          .cast<xml.XmlElement?>()
          .firstWhere(
            (xml.XmlElement? elem) => elem != null,
            orElse: () => null,
          );
      if (docTitleNode == null) {
        throw Exception(
          'EPUB parsing error: TOC file does not contain docTitle element.',
        );
      }

      final navigationDocTitle = readNavigationDocTitle(docTitleNode);

      result = result.copyWith(
        docTitle: navigationDocTitle,
        docAuthors: <EpubNavigationDocAuthor>[],
      );

      ncxNode.findElements('docAuthor', namespace: ncxNamespace).forEach((
        xml.XmlElement docAuthorNode,
      ) {
        final navigationDocAuthor = readNavigationDocAuthor(docAuthorNode);
        result.docAuthors!.add(navigationDocAuthor);
      });

      final navMapNode = ncxNode
          .findElements('navMap', namespace: ncxNamespace)
          .cast<xml.XmlElement?>()
          .firstWhere(
            (xml.XmlElement? elem) => elem != null,
            orElse: () => null,
          );
      if (navMapNode == null) {
        throw Exception(
          'EPUB parsing error: TOC file does not contain navMap element.',
        );
      }

      final navMap = readNavigationMap(navMapNode);
      result = result.copyWith(
        navMap: navMap,
      );

      final pageListNode = ncxNode
          .findElements('pageList', namespace: ncxNamespace)
          .cast<xml.XmlElement?>()
          .firstWhere(
            (xml.XmlElement? elem) => elem != null,
            orElse: () => null,
          );

      if (pageListNode != null) {
        final pageList = readNavigationPageList(pageListNode);
        result = result.copyWith(
          pageList: pageList,
        );
      }

      ncxNode.findElements('navList', namespace: ncxNamespace).forEach((
        xml.XmlElement navigationListNode,
      ) {
        final navigationList = readNavigationList(navigationListNode);
        result.navLists!.add(navigationList);
      });
    } else {
      //Version 3

      final tocManifestItem = package.manifest!.items!
          .cast<EpubManifestItem?>()
          .firstWhere(
            (element) => element!.properties == 'nav',
            orElse: () => null,
          );
      if (tocManifestItem == null) {
        throw Exception(
          'EPUB parsing error: TOC item, not found in EPUB manifest.',
        );
      }

      _tocFileEntryPath = ZipPathUtils.combine(
        contentDirectoryPath,
        tocManifestItem.href,
      );
      final tocFileEntry = epubArchive.files.cast<ArchiveFile?>().firstWhere(
        (ArchiveFile? file) =>
            file!.name.toLowerCase() == _tocFileEntryPath!.toLowerCase(),
        orElse: () => null,
      );
      if (tocFileEntry == null) {
        throw Exception(
          'EPUB parsing error: TOC file $_tocFileEntryPath not found in archive.',
        );
      }
      //Get relative toc file path
      _tocFileEntryPath =
          '${((_tocFileEntryPath!.split(
            '/',
          )..removeLast())..removeAt(0)).join('/')}/';

      final containerDocument = xml.XmlDocument.parse(
        convert.utf8.decode(tocFileEntry.content as List<int>? ?? []),
      );

      final headNode = containerDocument
          .findAllElements('head')
          .cast<xml.XmlElement?>()
          .firstWhere(
            (xml.XmlElement? elem) => elem != null,
            orElse: () => null,
          );
      if (headNode == null) {
        throw Exception(
          'EPUB parsing error: TOC file does not contain head element.',
        );
      }

      result = result.copyWith(
        docTitle: EpubNavigationDocTitle(
          titles: package.metadata!.titles,
        ),
      );

      //      result.DocTitle.Titles.add(headNode.findAllElements("title").firstWhere((element) =>  element != null, orElse: () => null).text.trim());

      final navNode = containerDocument
          .findAllElements('nav')
          .cast<xml.XmlElement?>()
          .firstWhere(
            (xml.XmlElement? elem) => elem != null,
            orElse: () => null,
          );
      if (navNode == null) {
        throw Exception(
          'EPUB parsing error: TOC file does not contain head element.',
        );
      }
      final navMapNode = navNode.findElements('ol').single;

      final navMap = readNavigationMapV3(navMapNode);
      result = result.copyWith(
        navMap: navMap,
      );

      final pageListNode = containerDocument
          .findAllElements('nav')
          .where((element) => element.getAttribute('epub:type') == 'page-list')
          .firstOrNull;
      if (pageListNode != null) {
        final pageList = readNavigationPageListEpubV3(pageListNode);
        result = result.copyWith(
          pageList: pageList,
        );
      }
    }

    return result;
  }

  EpubNavigationContent readNavigationContent(
    xml.XmlElement navigationContentNode,
  ) {
    var result = const EpubNavigationContent();

    for (final navigationContentNodeAttribute
        in navigationContentNode.attributes) {
      final attributeValue = navigationContentNodeAttribute.value;
      switch (navigationContentNodeAttribute.name.local.toLowerCase()) {
        case 'id':
          result = result.copyWith(
            id: attributeValue,
          );
        case 'src':
          result = result.copyWith(
            source: attributeValue,
          );
      }
    }
    if (result.source == null || result.source!.isEmpty) {
      throw Exception(
        'Incorrect EPUB navigation content: content source is missing.',
      );
    }

    return result;
  }

  EpubNavigationContent readNavigationContentV3(
    xml.XmlElement navigationContentNode,
  ) {
    var result = const EpubNavigationContent();

    for (final navigationContentNodeAttribute
        in navigationContentNode.attributes) {
      final attributeValue = navigationContentNodeAttribute.value;
      switch (navigationContentNodeAttribute.name.local.toLowerCase()) {
        case 'id':
          result = result.copyWith(
            id: attributeValue,
          );
        case 'href':
          if (_tocFileEntryPath!.length < 2 ||
              attributeValue.startsWith(_tocFileEntryPath!)) {
            result = result.copyWith(
              source: attributeValue,
            );
          } else {
            result = result.copyWith(
              source: path.normalize(_tocFileEntryPath! + attributeValue),
            );
          }
      }
    }

    // element with span, the content will be null;
    // if (result.Source == null || result.Source!.isEmpty) {
    //   throw Exception(
    //       'Incorrect EPUB navigation content: content source is missing.');
    // }
    return result;
  }

  String extractContentPath(String tocFileEntryPath, String ref) {
    final completeTocFileEntryPath =
        '$tocFileEntryPath${tocFileEntryPath.endsWith('/') ? '' : '/'}';

    var r = completeTocFileEntryPath + ref;
    r = r.replaceAll('/./', '/');
    r = r.replaceAll(RegExp(r'/[^/]+/\.\./'), '/');
    r = r.replaceAll(RegExp(r'^[^/]+/\.\./'), '');
    return r;
  }

  EpubNavigationDocAuthor readNavigationDocAuthor(
    xml.XmlElement docAuthorNode,
  ) {
    const result = EpubNavigationDocAuthor(
      authors: <String>[],
    );

    docAuthorNode.children.whereType<xml.XmlElement>().forEach((
      xml.XmlElement textNode,
    ) {
      if (textNode.name.local.toLowerCase() == 'text') {
        result.authors!.add(textNode.value ?? '');
      }
    });
    return result;
  }

  EpubNavigationDocTitle readNavigationDocTitle(xml.XmlElement docTitleNode) {
    const result = EpubNavigationDocTitle(
      titles: <String>[],
    );

    docTitleNode.children.whereType<xml.XmlElement>().forEach((
      xml.XmlElement textNode,
    ) {
      if (textNode.name.local.toLowerCase() == 'text') {
        result.titles!.add(textNode.value ?? '');
      }
    });

    return result;
  }

  EpubNavigationHead readNavigationHead(xml.XmlElement headNode) {
    const result = EpubNavigationHead(
      metadata: <EpubNavigationHeadMeta>[],
    );

    headNode.children.whereType<xml.XmlElement>().forEach((
      xml.XmlElement metaNode,
    ) {
      if (metaNode.name.local.toLowerCase() == 'meta') {
        var meta = const EpubNavigationHeadMeta();

        for (final metaNodeAttribute in metaNode.attributes) {
          final attributeValue = metaNodeAttribute.value;
          switch (metaNodeAttribute.name.local.toLowerCase()) {
            case 'name':
              meta = meta.copyWith(
                name: attributeValue,
              );
            case 'content':
              meta = meta.copyWith(
                content: attributeValue,
              );
            case 'scheme':
              meta = meta.copyWith(
                scheme: attributeValue,
              );
          }
        }

        if (meta.name == null || meta.name!.isEmpty) {
          throw Exception(
            'Incorrect EPUB navigation meta: meta name is missing.',
          );
        }
        if (meta.content == null) {
          throw Exception(
            'Incorrect EPUB navigation meta: meta content is missing.',
          );
        }

        result.metadata!.add(meta);
      }
    });
    return result;
  }

  EpubNavigationLabel readNavigationLabel(xml.XmlElement navigationLabelNode) {
    final navigationLabelTextNode = navigationLabelNode
        .findElements('text', namespace: navigationLabelNode.name.namespaceUri)
        .firstWhereOrNull((xml.XmlElement? elem) => elem != null);
    if (navigationLabelTextNode == null) {
      throw Exception(
        'Incorrect EPUB navigation label: label text element is missing.',
      );
    }

    return EpubNavigationLabel(
      text: navigationLabelTextNode.innerText,
    );
  }

  EpubNavigationLabel readNavigationLabelV3(
    xml.XmlElement navigationLabelNode,
  ) => EpubNavigationLabel(
    text: navigationLabelNode.innerText,
  );

  EpubNavigationList readNavigationList(xml.XmlElement navigationListNode) {
    var result = const EpubNavigationList();

    for (final navigationListNodeAttribute in navigationListNode.attributes) {
      final attributeValue = navigationListNodeAttribute.value;
      switch (navigationListNodeAttribute.name.local.toLowerCase()) {
        case 'id':
          result = result.copyWith(
            id: attributeValue,
          );
        case 'class':
          result = result.copyWith(
            navigationClass: attributeValue,
          );
      }
    }

    navigationListNode.children.whereType<xml.XmlElement>().forEach((
      xml.XmlElement navigationListChildNode,
    ) {
      switch (navigationListChildNode.name.local.toLowerCase()) {
        case 'navlabel':
          final navigationLabel = readNavigationLabel(navigationListChildNode);
          result.navigationLabels!.add(navigationLabel);
        case 'navtarget':
          final navigationTarget = readNavigationTarget(
            navigationListChildNode,
          );
          result.navigationTargets!.add(navigationTarget);
      }
    });
    // if (result.NavigationLabels!.isEmpty) {
    //   throw Exception(
    //       'Incorrect EPUB navigation page target: at least one navLabel element is required.');
    // }
    return result;
  }

  EpubNavigationMap readNavigationMap(xml.XmlElement navigationMapNode) {
    const result = EpubNavigationMap(points: <EpubNavigationPoint>[]);

    navigationMapNode.children.whereType<xml.XmlElement>().forEach((
      xml.XmlElement navigationPointNode,
    ) {
      if (navigationPointNode.name.local.toLowerCase() == 'navpoint') {
        final navigationPoint = readNavigationPoint(navigationPointNode);
        result.points!.add(navigationPoint);
      }
    });

    return result;
  }

  EpubNavigationMap readNavigationMapV3(xml.XmlElement navigationMapNode) {
    const result = EpubNavigationMap(
      points: <EpubNavigationPoint>[],
    );

    navigationMapNode.children.whereType<xml.XmlElement>().forEach((
      xml.XmlElement navigationPointNode,
    ) {
      if (navigationPointNode.name.local.toLowerCase() == 'li') {
        final navigationPoint = readNavigationPointV3(navigationPointNode);
        result.points!.add(navigationPoint);
      }
    });

    return result;
  }

  EpubNavigationPageList readNavigationPageList(
    xml.XmlElement navigationPageListNode,
  ) {
    const result = EpubNavigationPageList(
      targets: <EpubNavigationPageTarget>[],
    );

    navigationPageListNode.descendantElements
        .whereType<xml.XmlElement>()
        .forEach((xml.XmlElement pageTargetNode) {
          if (pageTargetNode.name.local == 'pageTarget') {
            final pageTarget = readNavigationPageTarget(pageTargetNode);
            result.targets!.add(pageTarget);
          }
        });

    return result;
  }

  EpubNavigationPageList readNavigationPageListEpubV3(
    xml.XmlElement navigationPageListNode,
  ) {
    const result = EpubNavigationPageList(
      targets: <EpubNavigationPageTarget>[],
    );

    final liElements = navigationPageListNode.findAllElements('li');
    for (final liElement in liElements) {
      final aElement = liElement.findElements('a').first;
      final text = aElement.value ?? aElement.innerText;

      final pageTarget = EpubNavigationPageTarget(
        value: text,
        id: text,
      );

      result.targets!.add(pageTarget);
    }

    navigationPageListNode.descendantElements
        .whereType<xml.XmlElement>()
        .forEach((xml.XmlElement pageTargetNode) {
          if (pageTargetNode.name.local == 'pageTarget') {}
        });

    return result;
  }

  EpubNavigationPageTarget readNavigationPageTarget(
    xml.XmlElement navigationPageTargetNode,
  ) {
    var result = const EpubNavigationPageTarget(
      navigationLabels: <EpubNavigationLabel>[],
    );

    for (final navigationPageTargetNodeAttribute
        in navigationPageTargetNode.attributes) {
      final attributeValue = navigationPageTargetNodeAttribute.value;
      switch (navigationPageTargetNodeAttribute.name.local.toLowerCase()) {
        case 'id':
          result = result.copyWith(
            id: attributeValue,
          );
        case 'value':
          result = result.copyWith(
            value: attributeValue,
          );
        case 'type':
          final type = EpubNavigationPageTargetType.values
              .asNameMap()[attributeValue.toLowerCase()];
          result = result.copyWith(
            type: type,
          );
        case 'class':
          result = result.copyWith(
            navigationClass: attributeValue,
          );
        case 'playorder':
          result = result.copyWith(
            playOrder: attributeValue,
          );
      }
    }
    if (result.type == EpubNavigationPageTargetType.undefined) {
      throw Exception(
        'Incorrect EPUB navigation page target: page target type is missing.',
      );
    }

    navigationPageTargetNode.children.whereType<xml.XmlElement>().forEach((
      xml.XmlElement navigationPageTargetChildNode,
    ) {
      switch (navigationPageTargetChildNode.name.local.toLowerCase()) {
        case 'navlabel':
          final navigationLabel = readNavigationLabel(
            navigationPageTargetChildNode,
          );
          result.navigationLabels!.add(navigationLabel);
        case 'content':
          final content = readNavigationContent(navigationPageTargetChildNode);
          result = result.copyWith(
            content: content,
          );
      }
    });
    if (result.navigationLabels!.isEmpty) {
      throw Exception(
        'Incorrect EPUB navigation page target: at least one navLabel element is required.',
      );
    }

    return result;
  }

  EpubNavigationPoint readNavigationPoint(xml.XmlElement navigationPointNode) {
    var result = const EpubNavigationPoint(
      navigationLabels: <EpubNavigationLabel>[],
      childNavigationPoints: <EpubNavigationPoint>[],
    );

    for (final navigationPointNodeAttribute in navigationPointNode.attributes) {
      final attributeValue = navigationPointNodeAttribute.value;
      switch (navigationPointNodeAttribute.name.local.toLowerCase()) {
        case 'id':
          result = result.copyWith(
            id: attributeValue,
          );
        case 'class':
          result = result.copyWith(
            navigationClass: attributeValue,
          );
        case 'playorder':
          result = result.copyWith(
            playOrder: attributeValue,
          );
      }
    }
    if (result.id == null || result.id!.isEmpty) {
      throw Exception('Incorrect EPUB navigation point: point ID is missing.');
    }

    navigationPointNode.children.whereType<xml.XmlElement>().forEach((
      xml.XmlElement navigationPointChildNode,
    ) {
      switch (navigationPointChildNode.name.local.toLowerCase()) {
        case 'navlabel':
          final navigationLabel = readNavigationLabel(navigationPointChildNode);
          result.navigationLabels!.add(navigationLabel);
        case 'content':
          final content = readNavigationContent(navigationPointChildNode);
          result.copyWith(
            content: content,
          );
        case 'navpoint':
          final childNavigationPoint = readNavigationPoint(
            navigationPointChildNode,
          );
          result.childNavigationPoints!.add(childNavigationPoint);
      }
    });

    if (result.navigationLabels!.isEmpty) {
      throw Exception(
        'EPUB parsing error: navigation point ${result.id} should contain at least one navigation label.',
      );
    }
    if (result.content == null) {
      throw Exception(
        'EPUB parsing error: navigation point ${result.id} should contain content.',
      );
    }

    return result;
  }

  EpubNavigationPoint readNavigationPointV3(
    xml.XmlElement navigationPointNode,
  ) {
    const result = EpubNavigationPoint(
      navigationLabels: <EpubNavigationLabel>[],
      childNavigationPoints: <EpubNavigationPoint>[],
    );

    navigationPointNode.children.whereType<xml.XmlElement>().forEach((
      xml.XmlElement navigationPointChildNode,
    ) {
      switch (navigationPointChildNode.name.local.toLowerCase()) {
        case 'a':
        case 'span':
          final navigationLabel = readNavigationLabelV3(
            navigationPointChildNode,
          );
          result.navigationLabels!.add(navigationLabel);
          final content = readNavigationContentV3(navigationPointChildNode);
          result.copyWith(
            content: content,
          );
        case 'ol':
          readNavigationMapV3(
            navigationPointChildNode,
          ).points!.forEach(result.childNavigationPoints!.add);
      }
    });

    if (result.navigationLabels!.isEmpty) {
      throw Exception(
        'EPUB parsing error: navigation point ${result.id} should contain at least one navigation label.',
      );
    }
    if (result.content == null) {
      throw Exception(
        'EPUB parsing error: navigation point ${result.id} should contain content.',
      );
    }

    return result;
  }

  EpubNavigationTarget readNavigationTarget(
    xml.XmlElement navigationTargetNode,
  ) {
    var result = const EpubNavigationTarget();

    for (final navigationPageTargetNodeAttribute
        in navigationTargetNode.attributes) {
      final attributeValue = navigationPageTargetNodeAttribute.value;
      switch (navigationPageTargetNodeAttribute.name.local.toLowerCase()) {
        case 'id':
          result = result.copyWith(
            id: attributeValue,
          );
        case 'value':
          result = result.copyWith(
            value: attributeValue,
          );
        case 'class':
          result = result.copyWith(
            navigationClass: attributeValue,
          );
        case 'playorder':
          result = result.copyWith(
            playOrder: attributeValue,
          );
      }
    }
    if (result.id == null || result.id!.isEmpty) {
      throw Exception(
        'Incorrect EPUB navigation target: navigation target ID is missing.',
      );
    }

    navigationTargetNode.children.whereType<xml.XmlElement>().forEach((
      xml.XmlElement navigationTargetChildNode,
    ) {
      switch (navigationTargetChildNode.name.local.toLowerCase()) {
        case 'navlabel':
          final navigationLabel = readNavigationLabel(
            navigationTargetChildNode,
          );
          result.navigationLabels!.add(navigationLabel);
        case 'content':
          final content = readNavigationContent(navigationTargetChildNode);

          result = result.copyWith(
            content: content,
          );
      }
    });
    if (result.navigationLabels!.isEmpty) {
      throw Exception(
        'Incorrect EPUB navigation target: at least one navLabel element is required.',
      );
    }

    return result;
  }
}
