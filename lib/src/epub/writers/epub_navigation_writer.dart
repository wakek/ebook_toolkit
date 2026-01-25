import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_doc_title.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_head.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_map.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_point.dart';
import 'package:xml/xml.dart';

class EpubNavigationWriter {
  factory EpubNavigationWriter() {
    return _singleton;
  }

  EpubNavigationWriter._internal();

  static final EpubNavigationWriter _singleton =
      EpubNavigationWriter._internal();

  static EpubNavigationWriter get instance => _singleton;

  static const String _namespace = 'http://www.daisy.org/z3986/2005/ncx/';

  String writeNavigation(EpubNavigation navigation) {
    final builder = XmlBuilder()..processing('xml', 'version="1.0"');

    builder.element(
      'ncx',
      attributes: {
        'version': '2005-1',
        'lang': 'en',
      },
      nest: () {
        builder.namespace(_namespace);

        writeNavigationHead(builder, navigation.head!);
        writeNavigationDocTitle(builder, navigation.docTitle!);
        writeNavigationMap(builder, navigation.navMap!);
      },
    );

    return builder.buildDocument().toXmlString();
  }

  void writeNavigationDocTitle(
    XmlBuilder builder,
    EpubNavigationDocTitle title,
  ) {
    builder.element(
      'docTitle',
      nest: () {
        title.titles!.forEach(builder.text);
      },
    );
  }

  void writeNavigationHead(XmlBuilder builder, EpubNavigationHead head) {
    builder.element(
      'head',
      nest: () {
        for (final item in head.metadata!) {
          builder.element(
            'meta',
            attributes: {'content': item.content!, 'name': item.name!},
          );
        }
      },
    );
  }

  static void writeNavigationMap(XmlBuilder builder, EpubNavigationMap map) {
    builder.element(
      'navMap',
      nest: () {
        for (final item in map.points!) {
          writeNavigationPoint(builder, item);
        }
      },
    );
  }

  static void writeNavigationPoint(
    XmlBuilder builder,
    EpubNavigationPoint point,
  ) {
    builder.element(
      'navPoint',
      attributes: {
        'id': point.id!,
        'playOrder': point.playOrder!,
      },
      nest: () {
        for (final element in point.navigationLabels!) {
          builder.element(
            'navLabel',
            nest: () {
              builder.element(
                'text',
                nest: () {
                  builder.text(element.text!);
                },
              );
            },
          );
        }
        builder.element('content', attributes: {'src': point.content!.source!});
      },
    );
  }
}
