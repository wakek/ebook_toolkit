import 'package:ebook_toolkit/src/epub/schema/opf/epub_package.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_version.dart';
import 'package:ebook_toolkit/src/epub/writers/epub_guide_writer.dart';
import 'package:ebook_toolkit/src/epub/writers/epub_manifest_writer.dart';
import 'package:ebook_toolkit/src/epub/writers/epub_metadata_writer.dart';
import 'package:ebook_toolkit/src/epub/writers/epub_spine_writer.dart';
import 'package:xml/xml.dart';

class EpubPackageWriter {
  factory EpubPackageWriter() {
    return _singleton;
  }

  EpubPackageWriter._internal();

  static final EpubPackageWriter _singleton = EpubPackageWriter._internal();

  static EpubPackageWriter get instance => _singleton;

  static const String _namespace = 'http://www.idpf.org/2007/opf';

  String writeContent(EpubPackage package) {
    final builder = XmlBuilder()..processing('xml', 'version="1.0"');

    builder.element(
      'package',
      attributes: {
        'version': package.version == EpubVersion.epub2 ? '2.0' : '3.0',
        'unique-identifier': 'etextno',
      },
      nest: () {
        builder.namespace(_namespace);

        EpubMetadataWriter().writeMetadata(
          builder,
          package.metadata,
          package.version,
        );
        EpubManifestWriter.instance.writeManifest(builder, package.manifest);
        EpubSpineWriter.instance.writeSpine(builder, package.spine!);
        EpubGuideWriter.instance.writeGuide(builder, package.guide);
      },
    );

    return builder.buildDocument().toXmlString();
  }
}
