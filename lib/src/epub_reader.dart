import 'dart:async';

import 'package:archive/archive.dart';

import 'package:ebook_toolkit/src/epub/entities/epub_book.dart';
import 'package:ebook_toolkit/src/epub/readers/content_reader.dart';
import 'package:ebook_toolkit/src/epub/readers/schema_reader.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_book_ref.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_creator.dart';

/// A class that provides the primary interface to read Epub files.
///
/// To open an Epub and load all data at once use the [readBook()] method.
///
/// To open an Epub and load only basic metadata use the [openBook()] method.
/// This is a good option to quickly load text-based metadata, while leaving the
/// heavier lifting of loading images and main content for subsequent operations.
///
/// ## Example
/// ```dart
/// // Read the basic metadata.
/// EpubBookRef epub = await EpubReader().openBook(epubFileBytes);
/// // Extract values of interest.
/// String title = epub.Title;
/// String author = epub.Author;
/// var metadata = epub.Schema.Package.Metadata;
/// String genres = metadata.Subjects.join(', ');
/// ```
class EpubReader {
  /// Loads basics metadata.
  ///
  /// Opens the book asynchronously without reading its main content.
  /// Holds the handle to the EPUB file.
  ///
  /// Argument [bytes] should be the bytes of
  /// the epub file you have loaded with something like the [dart:io] package's
  /// [readAsBytes()].
  ///
  /// This is a fast and convenient way to get the most important information
  /// about the book, notably the Title, Author and AuthorList.
  /// Additional information is loaded in the Schema property such as the
  /// Epub version, Publishers, Languages and more.
  Future<EpubBookRef> openBook(FutureOr<List<int>> bytes) async {
    List<int> loadedBytes;
    if (bytes is Future) {
      loadedBytes = await bytes;
    } else {
      loadedBytes = bytes;
    }

    final epubArchive = ZipDecoder().decodeBytes(loadedBytes);

    final bookRef = EpubBookRef(
      epubArchive: epubArchive,
      schema: await SchemaReader.instance.readSchema(epubArchive),
    );

    return bookRef.copyWith(
      title: bookRef.schema!.package!.metadata!.titles!.firstWhere(
        (String name) => true,
        orElse: () => '',
      ),
      authorList: bookRef.schema!.package!.metadata!.creators!
          .map((EpubMetadataCreator creator) => creator.creator)
          .toList(),
      author: bookRef.schema!.package!.metadata!.creators!
          .map((EpubMetadataCreator creator) => creator.creator)
          .toList()
          .join(', '),
      content: ContentReader().parseContentMap(bookRef),
    );
  }

  /// Opens the book asynchronously and reads all of its content into the memory. Does not hold the handle to the EPUB file.
  Future<EpubBook> readBook(FutureOr<List<int>> bytes) async {
    List<int> loadedBytes;
    if (bytes is Future) {
      loadedBytes = await bytes;
    } else {
      loadedBytes = bytes;
    }

    return EpubBook.fromRef(await openBook(loadedBytes));
  }
}
