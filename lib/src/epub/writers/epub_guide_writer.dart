import 'package:ebook_toolkit/src/epub/schema/opf/epub_guide.dart';
import 'package:xml/xml.dart';

class EpubGuideWriter {
  factory EpubGuideWriter() {
    return _singleton;
  }

  EpubGuideWriter._internal();

  static final EpubGuideWriter _singleton = EpubGuideWriter._internal();

  static EpubGuideWriter get instance => _singleton;

  void writeGuide(XmlBuilder builder, EpubGuide? guide) {
    builder.element(
      'guide',
      nest: () {
        for (final guideItem in guide!.items!) {
          builder.element(
            'reference',
            attributes: {
              'type': guideItem.type!,
              'title': guideItem.title!,
              'href': guideItem.href!,
            },
          );
        }
      },
    );
  }
}
