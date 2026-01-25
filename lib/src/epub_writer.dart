import 'dart:convert' as convert;

import 'package:archive/archive.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_book.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_byte_content_file.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_text_content_file.dart';
import 'package:ebook_toolkit/src/epub/writers/epub_package_writer.dart';
import 'package:ebook_toolkit/src/utils/zip_path_utils.dart';

class EpubWriter {
  factory EpubWriter() {
    return _singleton;
  }

  EpubWriter._internal();

  static final EpubWriter _singleton = EpubWriter._internal();

  static EpubWriter get instance => _singleton;

  static const _containerFile =
      '<?xml version="1.0"?><container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles></container>';

  // Creates a Zip Archive of an EpubBook
  Archive _createArchive(EpubBook book) {
    final arch = Archive()
      // Add simple metadata
      ..addFile(
        ArchiveFile.noCompress(
          'mimetype',
          20,
          convert.utf8.encode('application/epub+zip'),
        ),
      )
      // Add Container file
      ..addFile(
        ArchiveFile(
          'META-INF/container.xml',
          _containerFile.length,
          convert.utf8.encode(_containerFile),
        ),
      );

    // Add all content to the archive
    book.content!.allFiles!.forEach((name, file) {
      List<int>? content;

      if (file is EpubByteContentFile) {
        content = file.content;
      } else if (file is EpubTextContentFile) {
        content = convert.utf8.encode(file.content!);
      }

      arch.addFile(
        ArchiveFile(
          ZipPathUtils.combine(book.schema!.contentDirectoryPath, name)!,
          content!.length,
          content,
        ),
      );
    });

    // Generate the content.opf file and add it to the Archive
    final contentopf = EpubPackageWriter.instance.writeContent(
      book.schema!.package!,
    );

    arch.addFile(
      ArchiveFile(
        ZipPathUtils.combine(book.schema!.contentDirectoryPath, 'content.opf')!,
        contentopf.length,
        convert.utf8.encode(contentopf),
      ),
    );

    return arch;
  }

  // Serializes the EpubBook into a byte array
  List<int>? writeBook(EpubBook book) {
    final arch = _createArchive(book);

    return ZipEncoder().encode(arch);
  }
}
