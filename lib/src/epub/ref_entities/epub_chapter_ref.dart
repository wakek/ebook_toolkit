import 'dart:async';

import 'package:ebook_toolkit/src/epub/ref_entities/epub_text_content_file_ref.dart';
import 'package:equatable/equatable.dart';

class EpubChapterRef extends Equatable {
  const EpubChapterRef({
    this.epubTextContentFileRef,
    this.title,
    this.contentFileName,
    this.anchor,
    this.subChapters,
  });

  final EpubTextContentFileRef? epubTextContentFileRef;
  final String? title;
  final String? contentFileName;
  final String? anchor;
  final List<EpubChapterRef>? subChapters;

  Future<String> readHtmlContent() async {
    return epubTextContentFileRef?.readContentAsText() ?? Future.value('');
  }

  @override
  String toString() {
    return 'Title: $title, Subchapter count: ${subChapters?.length ?? 0}';
  }

  @override
  List<Object?> get props => [
    epubTextContentFileRef,
    title,
    contentFileName,
    anchor,
    subChapters,
  ];
}
