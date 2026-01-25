import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:ebook_toolkit/src/epub/ref_entities/epub_book_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_byte_content_file_ref.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_manifest_item.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_metadata_meta.dart';
import 'package:image/image.dart';

class BookCoverReader {
  factory BookCoverReader() {
    return _singleton;
  }

  BookCoverReader._internal();

  static final BookCoverReader _singleton = BookCoverReader._internal();

  static BookCoverReader get instance => _singleton;

  Future<Image?> readBookCover(EpubBookRef bookRef) async {
    final metaItems = bookRef.schema!.package!.metadata!.metaItems;
    if (metaItems == null || metaItems.isEmpty) {
      return null;
    }

    final coverMetaItem = metaItems.firstWhereOrNull(
      (EpubMetadataMeta metaItem) =>
          metaItem.name != null && metaItem.name!.toLowerCase() == 'cover',
    );
    if (coverMetaItem == null) {
      return null;
    }
    if (coverMetaItem.content == null || coverMetaItem.content!.isEmpty) {
      throw Exception(
        'Incorrect EPUB metadata: cover item content is missing.',
      );
    }

    final coverManifestItem = bookRef.schema!.package!.manifest!.items!
        .firstWhereOrNull(
          (EpubManifestItem manifestItem) =>
              manifestItem.id!.toLowerCase() ==
              coverMetaItem.content!.toLowerCase(),
        );
    if (coverManifestItem == null) {
      throw Exception(
        'Incorrect EPUB manifest: item with ID = "${coverMetaItem.content}" is missing.',
      );
    }

    EpubByteContentFileRef? coverImageContentFileRef;
    if (!bookRef.content!.images!.containsKey(coverManifestItem.href)) {
      throw Exception(
        'Incorrect EPUB manifest: item with href = "${coverManifestItem.href}" is missing.',
      );
    }

    coverImageContentFileRef = bookRef.content!.images![coverManifestItem.href];
    final coverImageContent = await coverImageContentFileRef!
        .readContentAsBytes();

    return decodeImage(Uint8List.fromList(coverImageContent));
  }
}
