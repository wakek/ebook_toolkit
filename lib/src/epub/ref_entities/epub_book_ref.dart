import 'dart:async';

import 'package:archive/archive.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_schema.dart';
import 'package:ebook_toolkit/src/epub/readers/book_cover_reader.dart';
import 'package:ebook_toolkit/src/epub/readers/chapter_reader.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_chapter_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_content_ref.dart';
import 'package:equatable/equatable.dart';
import 'package:image/image.dart';

class EpubBookRef extends Equatable {
  const EpubBookRef({
    this.epubArchive,
    this.title,
    this.author,
    this.authorList,
    this.schema,
    this.content,
  });

  final Archive? epubArchive;
  final String? title;
  final String? author;
  final List<String?>? authorList;
  final EpubSchema? schema;
  final EpubContentRef? content;

  Future<List<EpubChapterRef>> getChapters() async {
    return ChapterReader.getChapters(this);
  }

  Future<Image?> readCover() async {
    return BookCoverReader.instance.readBookCover(this);
  }

  EpubBookRef copyWith({
    Archive? epubArchive,
    String? title,
    String? author,
    List<String?>? authorList,
    EpubSchema? schema,
    EpubContentRef? content,
  }) {
    return EpubBookRef(
      epubArchive: epubArchive ?? this.epubArchive,
      title: title ?? this.title,
      author: author ?? this.author,
      authorList: authorList ?? this.authorList,
      schema: schema ?? this.schema,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [
    title,
    author,
    authorList,
    schema,
    content,
  ];
}
