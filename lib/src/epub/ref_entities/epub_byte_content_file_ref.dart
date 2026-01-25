import 'dart:async';

import 'package:ebook_toolkit/src/epub/ref_entities/epub_content_file_ref.dart';

class EpubByteContentFileRef extends EpubContentFileRef {
  const EpubByteContentFileRef({
    required super.epubBookRef,
    super.fileName,
    super.contentType,
    super.contentMimeType,
  });

  Future<List<int>> readContent() {
    return readContentAsBytes();
  }
}
