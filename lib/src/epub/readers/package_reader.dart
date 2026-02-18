import 'dart:async';
import 'dart:convert' as convert;

import 'package:archive/archive.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ebook_toolkit/src/epub/schema/opf/epub_guide.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_guide_reference.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_manifest.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_manifest_item.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_contributor.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_creator.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_date.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_identifier.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_meta.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_package.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_spine.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_spine_item_ref.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_version.dart';
import 'package:xml/xml.dart';

class PackageReader {
  factory PackageReader() {
    return _singleton;
  }

  PackageReader._internal();

  static final PackageReader _singleton = PackageReader._internal();

  static PackageReader get instance => _singleton;

  EpubGuide readGuide(XmlElement guideNode) {
    final items = <EpubGuideReference>[];

    guideNode.children.whereType<XmlElement>().forEach((
      XmlElement guideReferenceNode,
    ) {
      if (guideReferenceNode.name.local.toLowerCase() == 'reference') {
        var guideReference = const EpubGuideReference();

        for (final guideReferenceNodeAttribute
            in guideReferenceNode.attributes) {
          final attributeValue = guideReferenceNodeAttribute.value;
          switch (guideReferenceNodeAttribute.name.local.toLowerCase()) {
            case 'type':
              guideReference = guideReference.copyWith(
                type: attributeValue,
              );
            case 'title':
              guideReference = guideReference.copyWith(
                title: attributeValue,
              );
            case 'href':
              guideReference = guideReference.copyWith(
                href: attributeValue,
              );
          }
        }
        if (guideReference.type?.isEmpty ?? true) {
          throw Exception('Incorrect EPUB guide: item type is missing');
        }
        if (guideReference.href?.isEmpty ?? true) {
          throw Exception('Incorrect EPUB guide: item href is missing');
        }
        items.add(guideReference);
      }
    });

    return EpubGuide(items: items);
  }

  EpubManifest readManifest(XmlElement manifestNode) {
    final items = <EpubManifestItem>[];

    manifestNode.children.whereType<XmlElement>().forEach((
      XmlElement manifestItemNode,
    ) {
      if (manifestItemNode.name.local.toLowerCase() == 'item') {
        var manifestItem = const EpubManifestItem();

        for (final manifestItemNodeAttribute in manifestItemNode.attributes) {
          final attributeValue = manifestItemNodeAttribute.value;
          switch (manifestItemNodeAttribute.name.local.toLowerCase()) {
            case 'id':
              manifestItem = manifestItem.copyWith(
                id: attributeValue,
              );
            case 'href':
              manifestItem = manifestItem.copyWith(
                href: attributeValue,
              );
            case 'media-type':
              manifestItem = manifestItem.copyWith(
                mediaType: attributeValue,
              );
            case 'media-overlay':
              manifestItem = manifestItem.copyWith(
                mediaOverlay: attributeValue,
              );
            case 'required-namespace':
              manifestItem = manifestItem.copyWith(
                requiredNamespace: attributeValue,
              );
            case 'required-modules':
              manifestItem = manifestItem.copyWith(
                requiredModules: attributeValue,
              );
            case 'fallback':
              manifestItem = manifestItem.copyWith(
                fallback: attributeValue,
              );
            case 'fallback-style':
              manifestItem = manifestItem.copyWith(
                fallbackStyle: attributeValue,
              );
            case 'properties':
              manifestItem = manifestItem.copyWith(
                properties: attributeValue,
              );
          }
        }

        if (manifestItem.id?.isEmpty ?? true) {
          throw Exception('Incorrect EPUB manifest: item ID is missing');
        }
        if (manifestItem.href?.isEmpty ?? true) {
          throw Exception('Incorrect EPUB manifest: item href is missing');
        }
        if (manifestItem.mediaType?.isEmpty ?? true) {
          throw Exception(
            'Incorrect EPUB manifest: item media type is missing',
          );
        }
        items.add(manifestItem);
      }
    });
    return EpubManifest(items: items);
  }

  EpubMetadata readMetadata(
    XmlElement metadataNode,
    EpubVersion? epubVersion,
  ) {
    var description = '';
    final titles = <String>[];
    final creators = <EpubMetadataCreator>[];
    final subjects = <String>[];
    final publishers = <String>[];
    final contributors = <EpubMetadataContributor>[];
    final dates = <EpubMetadataDate>[];
    final types = <String>[];
    final formats = <String>[];
    final identifiers = <EpubMetadataIdentifier>[];
    final sources = <String>[];
    final languages = <String>[];
    final relations = <String>[];
    final coverages = <String>[];
    final rights = <String>[];
    final metaItems = <EpubMetadataMeta>[];

    metadataNode.children.whereType<XmlElement>().forEach((
      XmlElement metadataItemNode,
    ) {
      switch (metadataItemNode.name.local.toLowerCase()) {
        case 'title':
          titles.add(
            metadataItemNode.value ?? metadataItemNode.innerText,
          );
        case 'creator':
          final creator = readMetadataCreator(metadataItemNode);
          creators.add(creator);
        case 'subject':
          subjects.add(metadataItemNode.innerText);
        case 'description':
          description = metadataItemNode.innerText;
        case 'publisher':
          publishers.add(metadataItemNode.innerText);
        case 'contributor':
          final contributor = readMetadataContributor(metadataItemNode);
          contributors.add(contributor);
        case 'date':
          final date = readMetadataDate(metadataItemNode);
          dates.add(date);
        case 'type':
          types.add(metadataItemNode.innerText);
        case 'format':
          formats.add(metadataItemNode.innerText);
        case 'identifier':
          final identifier = readMetadataIdentifier(metadataItemNode);
          identifiers.add(identifier);
        case 'source':
          sources.add(metadataItemNode.innerText);
        case 'language':
          languages.add(metadataItemNode.innerText);
        case 'relation':
          relations.add(metadataItemNode.innerText);
        case 'coverage':
          coverages.add(metadataItemNode.innerText);
        case 'rights':
          rights.add(metadataItemNode.innerText);
        case 'meta':
          if (epubVersion == EpubVersion.epub2) {
            final meta = readMetadataMetaVersion2(metadataItemNode);
            metaItems.add(meta);
          } else if (epubVersion == EpubVersion.epub3) {
            final meta = readMetadataMetaVersion3(metadataItemNode);
            metaItems.add(meta);
          }
      }
    });
    return EpubMetadata(
      titles: titles,
      creators: creators,
      subjects: subjects,
      description: description,
      publishers: publishers,
      contributors: contributors,
      dates: dates,
      types: types,
      formats: formats,
      identifiers: identifiers,
      sources: sources,
      languages: languages,
      relations: relations,
      coverages: coverages,
      rights: rights,
      metaItems: metaItems,
    );
  }

  EpubMetadataContributor readMetadataContributor(
    XmlElement metadataContributorNode,
  ) {
    var result = const EpubMetadataContributor();

    for (final metadataContributorNodeAttribute
        in metadataContributorNode.attributes) {
      final attributeValue = metadataContributorNodeAttribute.value;
      switch (metadataContributorNodeAttribute.name.local.toLowerCase()) {
        case 'role':
          result = result.copyWith(
            role: attributeValue,
          );
        case 'file-as':
          result = result.copyWith(
            fileAs: attributeValue,
          );
      }
    }

    return result.copyWith(
      contributor: metadataContributorNode.innerText,
    );
  }

  EpubMetadataCreator readMetadataCreator(
    XmlElement metadataCreatorNode,
  ) {
    var result = const EpubMetadataCreator();

    for (final metadataCreatorNodeAttribute in metadataCreatorNode.attributes) {
      final attributeValue = metadataCreatorNodeAttribute.value;
      switch (metadataCreatorNodeAttribute.name.local.toLowerCase()) {
        case 'role':
          result = result.copyWith(
            role: attributeValue,
          );
        case 'file-as':
          result = result.copyWith(
            fileAs: attributeValue,
          );
      }
    }
    return result.copyWith(
      creator: metadataCreatorNode.innerText,
    );
  }

  EpubMetadataDate readMetadataDate(XmlElement metadataDateNode) {
    var result = const EpubMetadataDate();

    final eventAttribute = metadataDateNode.getAttribute(
      'event',
      namespace: metadataDateNode.name.namespaceUri,
    );

    if (eventAttribute != null && eventAttribute.isNotEmpty) {
      result = result.copyWith(
        event: eventAttribute,
      );
    }

    return result.copyWith(date: metadataDateNode.innerText);
  }

  EpubMetadataIdentifier readMetadataIdentifier(
    XmlElement metadataIdentifierNode,
  ) {
    var result = const EpubMetadataIdentifier();

    for (final metadataIdentifierNodeAttribute
        in metadataIdentifierNode.attributes) {
      final attributeValue = metadataIdentifierNodeAttribute.value;
      switch (metadataIdentifierNodeAttribute.name.local.toLowerCase()) {
        case 'id':
          result = result.copyWith(
            id: attributeValue,
          );
        case 'scheme':
          result = result.copyWith(
            scheme: attributeValue,
          );
      }
    }
    return result.copyWith(
      identifier: metadataIdentifierNode.value,
    );
  }

  EpubMetadataMeta readMetadataMetaVersion2(
    XmlElement metadataMetaNode,
  ) {
    var result = const EpubMetadataMeta();

    for (final metadataMetaNodeAttribute in metadataMetaNode.attributes) {
      final attributeValue = metadataMetaNodeAttribute.value;
      switch (metadataMetaNodeAttribute.name.local.toLowerCase()) {
        case 'name':
          result = result.copyWith(name: attributeValue);
        case 'content':
          result = result.copyWith(content: attributeValue);
      }
    }
    return result;
  }

  EpubMetadataMeta readMetadataMetaVersion3(
    XmlElement metadataMetaNode,
  ) {
    var result = EpubMetadataMeta(
      content: metadataMetaNode.value,
    );

    final attributes = <String, String>{};

    for (final metadataMetaNodeAttribute in metadataMetaNode.attributes) {
      final attributeValue = metadataMetaNodeAttribute.value;

      attributes[metadataMetaNodeAttribute.name.local.toLowerCase()] =
          attributeValue;

      switch (metadataMetaNodeAttribute.name.local.toLowerCase()) {
        case 'id':
          result = result.copyWith(
            id: attributeValue,
          );
        // case 'name':
        //   result = result.copyWith(name: attributeValue);
        case 'scheme':
          result = result.copyWith(scheme: attributeValue);
        case 'property':
          result = result.copyWith(property: attributeValue);
        case 'refines':
          result = result.copyWith(refines: attributeValue);
      }
    }

    return result.copyWith(attributes: attributes);
  }

  Future<EpubPackage> readPackage(
    Archive epubArchive,
    String rootFilePath,
  ) async {
    final rootFileEntry = epubArchive.files.firstWhereOrNull(
      (ArchiveFile testFile) => testFile.name == rootFilePath,
    );
    if (rootFileEntry == null) {
      throw Exception('EPUB parsing error: root file not found in archive.');
    }
    final containerDocument = XmlDocument.parse(
      convert.utf8.decode(rootFileEntry.content as List<int>? ?? []),
    );
    const opfNamespace = 'http://www.idpf.org/2007/opf';

    final packageNode = containerDocument
        .findElements('package', namespace: opfNamespace)
        .firstWhere((XmlElement? elem) => elem != null);

    var result = const EpubPackage();

    final epubVersionValue = packageNode.getAttribute('version');

    if (epubVersionValue == '2.0') {
      result = result.copyWith(
        version: EpubVersion.epub2,
      );
    } else if (epubVersionValue == '3.0') {
      result = result.copyWith(
        version: EpubVersion.epub3,
      );
    } else {
      throw Exception('Unsupported EPUB version: $epubVersionValue.');
    }

    final metadataNode = packageNode
        .findElements('metadata', namespace: opfNamespace)
        .cast<XmlElement?>()
        .firstWhere((XmlElement? elem) => elem != null);

    if (metadataNode == null) {
      throw Exception('EPUB parsing error: metadata not found in the package.');
    }

    final metadata = readMetadata(metadataNode, result.version);

    result = result.copyWith(
      metadata: metadata,
    );

    final manifestNode = packageNode
        .findElements('manifest', namespace: opfNamespace)
        .cast<XmlElement?>()
        .firstWhere((XmlElement? elem) => elem != null);
    if (manifestNode == null) {
      throw Exception('EPUB parsing error: manifest not found in the package.');
    }

    final manifest = readManifest(manifestNode);

    result = result.copyWith(
      manifest: manifest,
    );

    final spineNode = packageNode
        .findElements('spine', namespace: opfNamespace)
        .cast<XmlElement?>()
        .firstWhere((XmlElement? elem) => elem != null);
    if (spineNode == null) {
      throw Exception('EPUB parsing error: spine not found in the package.');
    }

    final spine = readSpine(spineNode);

    result = result.copyWith(
      spine: spine,
    );

    final guideNode = packageNode
        .findElements('guide', namespace: opfNamespace)
        .firstWhereOrNull((XmlElement? elem) => elem != null);
    if (guideNode != null) {
      final guide = readGuide(guideNode);
      result = result.copyWith(
        guide: guide,
      );
    }

    return result;
  }

  EpubSpine readSpine(XmlElement spineNode) {
    final pageProgression = spineNode.getAttribute(
      'page-progression-direction',
    );

    final items = <EpubSpineItemRef>[];

    spineNode.children.whereType<XmlElement>().forEach((
      XmlElement spineItemNode,
    ) {
      if (spineItemNode.name.local.toLowerCase() == 'itemref') {
        final idRefAttribute = spineItemNode.getAttribute('idref');

        if (idRefAttribute == null || idRefAttribute.isEmpty) {
          throw Exception('Incorrect EPUB spine: item ID ref is missing');
        }

        final linearAttribute = spineItemNode.getAttribute('linear');

        items.add(
          EpubSpineItemRef(
            idRef: idRefAttribute,
            isLinear:
                linearAttribute == null ||
                (linearAttribute.toLowerCase() != 'no'),
          ),
        );
      }
    });

    return EpubSpine(
      items: items,
      tableOfContents: spineNode.getAttribute('toc'),
      ltr: (pageProgression == null) || pageProgression.toLowerCase() == 'ltr',
    );
  }
}
