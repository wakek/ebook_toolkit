import 'package:ebook_toolkit/src/epub/schema/opf/epub_spine.dart';
import 'package:xml/xml.dart';

class EpubSpineWriter {
  factory EpubSpineWriter() {
    return _singleton;
  }

  EpubSpineWriter._internal();

  static final EpubSpineWriter _singleton = EpubSpineWriter._internal();

  static EpubSpineWriter get instance => _singleton;

  void writeSpine(XmlBuilder builder, EpubSpine spine) {
    builder.element(
      'spine',
      attributes: {'toc': spine.tableOfContents!},
      nest: () {
        for (final spineitem in spine.items!) {
          builder.element(
            'itemref',
            attributes: {
              'idref': spineitem.idRef!,
              'linear': spineitem.isLinear! ? 'yes' : 'no',
            },
          );
        }
      },
    );
  }
}
