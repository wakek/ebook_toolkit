import 'dart:async';

import 'package:ebook_toolkit/src/epub/ref_entities/epub_content_file_ref.dart';

class EpubTextContentFileRef extends EpubContentFileRef {
  const EpubTextContentFileRef({
    required super.epubBookRef,
    super.fileName,
    super.contentType,
    super.contentMimeType,
  });

  Future<String> readContentAsync() async {
    return readContentAsText();
  }
}
