import 'package:ebook_toolkit/ebook_toolkit.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_spine.dart';
import 'package:xml/xml.dart';

class EpubSpineWriter {
  factory EpubSpineWriter() {
    return _singleton;
  }

  EpubSpineWriter._internal();

  static final EpubSpineWriter _singleton = EpubSpineWriter._internal();

  static EpubSpineWriter get instance => _singleton;

  void writeSpine(XmlBuilder builder, EpubSpine? spine) {
    if (spine == null) {
      return;
    }
    builder.element(
      'spine',
      attributes: {'toc': spine.tableOfContents ?? ''},
      nest: () {
        for (final spineitem in spine.items ?? <EpubSpineItemRef>[]) {
          builder.element(
            'itemref',
            attributes: {
              'idref': spineitem.idRef ?? '',
              'linear': (spineitem.isLinear ?? true) ? 'yes' : 'no',
            },
          );
        }
      },
    );
  }
}
