import 'dart:async';
import 'dart:convert' as convert;

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_content_type.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_book_ref.dart';
import 'package:ebook_toolkit/src/utils/zip_path_utils.dart';
import 'package:equatable/equatable.dart';

abstract class EpubContentFileRef extends Equatable {
  const EpubContentFileRef({
    required this.epubBookRef,
    this.fileName,
    this.contentType,
    this.contentMimeType,
  });

  final EpubBookRef epubBookRef;

  final String? fileName;
  final EpubContentType? contentType;
  final String? contentMimeType;

  @override
  List<Object?> get props => [
    epubBookRef,
    fileName,
    contentType,
    contentMimeType,
  ];

  ArchiveFile getContentFileEntry() {
    final schema = epubBookRef.schema;
    if (schema == null) {
      throw Exception('EPUB parsing error: schema is missing.');
    }
    final contentFilePath = ZipPathUtils.combine(
      schema.contentDirectoryPath,
      fileName,
    );
    final archive = epubBookRef.epubArchive;
    if (archive == null) {
      throw Exception('EPUB parsing error: archive is missing.');
    }
    final contentFileEntry = archive.files.firstWhereOrNull(
      (ArchiveFile x) => x.name == contentFilePath,
    );
    if (contentFileEntry == null) {
      throw Exception(
        'EPUB parsing error: file $contentFilePath not found in archive.',
      );
    }
    return contentFileEntry;
  }

  List<int> getContentStream() {
    return openContentStream(getContentFileEntry());
  }

  List<int> openContentStream(ArchiveFile contentFileEntry) {
    final contentStream = <int>[];
    if (contentFileEntry.content.isEmpty) {
      throw Exception(
        'Incorrect EPUB file: content file "$fileName" specified in manifest is not found.',
      );
    }
    contentStream.addAll(contentFileEntry.content as List<int>? ?? []);
    return contentStream;
  }

  Future<List<int>> readContentAsBytes() async {
    final contentFileEntry = getContentFileEntry();
    final content = openContentStream(contentFileEntry);
    return content;
  }

  Future<String> readContentAsText() async {
    final contentStream = getContentStream();
    final result = convert.utf8.decode(contentStream);
    return result;
  }
}
