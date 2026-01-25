import 'package:ebook_toolkit/src/epub/schema/opf/epub_manifest.dart';
import 'package:xml/xml.dart';

class EpubManifestWriter {
  factory EpubManifestWriter() {
    return _singleton;
  }

  EpubManifestWriter._internal();

  static final EpubManifestWriter _singleton = EpubManifestWriter._internal();

  static EpubManifestWriter get instance => _singleton;

  void writeManifest(XmlBuilder builder, EpubManifest? manifest) {
    builder.element(
      'manifest',
      nest: () {
        for (final item in manifest!.items!) {
          builder.element(
            'item',
            nest: () {
              builder
                ..attribute('id', item.id)
                ..attribute('href', item.href)
                ..attribute('media-type', item.mediaType);
            },
          );
        }
      },
    );
  }
}
