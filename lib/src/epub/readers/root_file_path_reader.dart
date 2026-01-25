import 'dart:async';
import 'dart:convert' as convert;

import 'package:archive/archive.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:xml/xml.dart' as xml;

class RootFilePathReader {
  factory RootFilePathReader() {
    return _singleton;
  }

  RootFilePathReader._internal();

  static final RootFilePathReader _singleton = RootFilePathReader._internal();

  static RootFilePathReader get instance => _singleton;

  Future<String?> getRootFilePath(Archive epubArchive) async {
    const epubContainerFilePath = 'META-INF/container.xml';

    final containerFileEntry = epubArchive.files.firstWhereOrNull(
      (ArchiveFile file) => file.name == epubContainerFilePath,
    );
    if (containerFileEntry == null) {
      throw Exception(
        'EPUB parsing error: $epubContainerFilePath file not found in archive.',
      );
    }

    final containerDocument = xml.XmlDocument.parse(
      convert.utf8.decode(containerFileEntry.content as List<int>? ?? []),
    );

    final packageElement = containerDocument
        .findAllElements(
          'container',
          namespace: 'urn:oasis:names:tc:opendocument:xmlns:container',
        )
        .firstWhereOrNull((xml.XmlElement? elem) => elem != null);

    if (packageElement == null) {
      throw Exception('EPUB parsing error: Invalid epub container');
    }

    final rootFileElement =
        packageElement.descendants.firstWhereOrNull(
              (xml.XmlNode testElem) =>
                  (testElem is xml.XmlElement) &&
                  'rootfile' == testElem.name.local,
            )
            as xml.XmlElement?;

    return rootFileElement?.getAttribute('full-path');
  }
}
