import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_version.dart';
import 'package:xml/xml.dart';

class EpubMetadataWriter {
  factory EpubMetadataWriter() {
    return _singleton;
  }

  EpubMetadataWriter._internal();

  static final EpubMetadataWriter _singleton = EpubMetadataWriter._internal();

  static EpubMetadataWriter get instance => _singleton;

  static const dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const opfNamespace = 'http://www.idpf.org/2007/opf';

  void writeMetadata(
    XmlBuilder builder,
    EpubMetadata? meta,
    EpubVersion? version,
  ) {
    builder.element(
      'metadata',
      namespaces: {opfNamespace: 'opf', dcNamespace: 'dc'},
      nest: () {
        meta!
          ..titles?.forEach(
            (item) =>
                builder.element('title', nest: item, namespace: dcNamespace),
          )
          ..creators?.forEach(
            (item) => builder.element(
              'creator',
              namespace: dcNamespace,
              nest: () {
                if (item.role != null) {
                  builder.attribute(
                    'role',
                    item.role,
                    namespace: opfNamespace,
                  );
                }
                if (item.fileAs != null) {
                  builder.attribute(
                    'file-as',
                    item.fileAs,
                    namespace: opfNamespace,
                  );
                }
                builder.text(item.creator!);
              },
            ),
          )
          ..subjects?.forEach(
            (item) => builder.element(
              'subject',
              namespace: dcNamespace,
              nest: item,
            ),
          )
          ..publishers?.forEach(
            (item) => builder.element(
              'publisher',
              namespace: dcNamespace,
              nest: item,
            ),
          )
          ..contributors?.forEach(
            (item) => builder.element(
              'contributor',
              namespace: dcNamespace,
              nest: () {
                if (item.role != null) {
                  builder.attribute(
                    'role',
                    item.role,
                    namespace: opfNamespace,
                  );
                }
                if (item.fileAs != null) {
                  builder.attribute(
                    'file-as',
                    item.fileAs,
                    namespace: opfNamespace,
                  );
                }
                builder.text(item.contributor!);
              },
            ),
          )
          ..dates?.forEach(
            (date) => builder.element(
              'date',
              namespace: dcNamespace,
              nest: () {
                if (date.event != null) {
                  builder.attribute(
                    'event',
                    date.event,
                    namespace: opfNamespace,
                  );
                }
                builder.text(date.date!);
              },
            ),
          )
          ..types?.forEach(
            (type) =>
                builder.element('type', namespace: dcNamespace, nest: type),
          )
          ..formats?.forEach(
            (format) => builder.element(
              'format',
              namespace: dcNamespace,
              nest: format,
            ),
          )
          ..identifiers?.forEach(
            (id) => builder.element(
              'identifier',
              namespace: dcNamespace,
              nest: () {
                if (id.id != null) {
                  builder.attribute('id', id.id);
                }
                if (id.scheme != null) {
                  builder.attribute(
                    'scheme',
                    id.scheme,
                    namespace: opfNamespace,
                  );
                }
                builder.text(id.identifier!);
              },
            ),
          )
          ..sources?.forEach(
            (item) =>
                builder.element('source', namespace: dcNamespace, nest: item),
          )
          ..languages?.forEach(
            (item) => builder.element(
              'language',
              namespace: dcNamespace,
              nest: item,
            ),
          )
          ..relations?.forEach(
            (item) => builder.element(
              'relation',
              namespace: dcNamespace,
              nest: item,
            ),
          )
          ..coverages?.forEach(
            (item) => builder.element(
              'coverage',
              namespace: dcNamespace,
              nest: item,
            ),
          )
          ..rights?.forEach(
            (item) =>
                builder.element('rights', namespace: dcNamespace, nest: item),
          )
          ..metaItems?.forEach(
            (metaitem) => builder.element(
              'meta',
              nest: () {
                if (version == EpubVersion.epub2) {
                  if (metaitem.name != null) {
                    builder.attribute('name', metaitem.name);
                  }
                  if (metaitem.content != null) {
                    builder.attribute('content', metaitem.content);
                  }
                } else if (version == EpubVersion.epub3) {
                  if (metaitem.id != null) {
                    builder.attribute('id', metaitem.id);
                  }
                  if (metaitem.refines != null) {
                    builder.attribute('refines', metaitem.refines);
                  }
                  if (metaitem.property != null) {
                    builder.attribute('property', metaitem.property);
                  }
                  if (metaitem.scheme != null) {
                    builder.attribute('scheme', metaitem.scheme);
                  }
                }
              },
            ),
          );

        if (meta.description != null) {
          builder.element(
            'description',
            namespace: dcNamespace,
            nest: meta.description,
          );
        }
      },
    );
  }
}
