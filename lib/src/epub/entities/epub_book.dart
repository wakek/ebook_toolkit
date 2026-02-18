import 'package:ebook_toolkit/ebook_toolkit.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_chapter.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_content.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_schema.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_content_file_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_content_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_text_content_file_ref.dart';
import 'package:equatable/equatable.dart';

class EpubBook extends Equatable {
  const EpubBook({
    this.title,
    this.author,
    this.authorList,
    this.schema,
    this.content,
    this.coverImageBytes,
    this.chapters,
  });

  final String? title;
  final String? author;
  final List<String?>? authorList;
  final EpubSchema? schema;
  final EpubContent? content;
  final List<int>? coverImageBytes;
  final List<EpubChapter>? chapters;

  @override
  List<Object?> get props => [
    title,
    author,
    authorList,
    schema,
    content,
    coverImageBytes,
    chapters,
  ];

  EpubBook copyWith({
    String? title,
    String? author,
    List<String?>? authorList,
    EpubSchema? schema,
    EpubContent? content,
    List<int>? coverImageBytes,
    List<EpubChapter>? chapters,
  }) {
    return EpubBook(
      title: title ?? this.title,
      author: author ?? this.author,
      authorList: authorList ?? this.authorList,
      schema: schema ?? this.schema,
      content: content ?? this.content,
      coverImageBytes: coverImageBytes ?? this.coverImageBytes,
      chapters: chapters ?? this.chapters,
    );
  }

  static Future<EpubBook> fromRef(EpubBookRef ref) async {
    return EpubBook(
      title: ref.title,
      author: ref.author,
      authorList: ref.authorList,
      schema: ref.schema,
      content: await readContent(ref.content ?? const EpubContentRef()),
      coverImageBytes: (await ref.readCover())?.toUint8List(),
      chapters: await readChapters(await ref.getChapters()),
    );
  }

  static Future<EpubContent> readContent(EpubContentRef contentRef) async {
    final html = await readTextContentFiles(contentRef.html ?? {});
    final css = await readTextContentFiles(contentRef.css ?? {});
    final images = await readByteContentFiles(contentRef.images ?? {});
    final fonts = await readByteContentFiles(contentRef.fonts ?? {});
    final allFiles = <String, EpubContentFile>{};

    html.forEach((key, value) => allFiles[key] = value);
    css.forEach((key, value) => allFiles[key] = value);
    images.forEach((key, value) => allFiles[key] = value);
    fonts.forEach((key, value) => allFiles[key] = value);

    await Future.forEach(contentRef.allFiles?.keys ?? <String>[],
        (String key) async {
      if (!allFiles.containsKey(key)) {
        final fileRef = contentRef.allFiles?[key];
        if (fileRef != null) {
          allFiles[key] = await readByteContentFile(fileRef);
        }
      }
    });

    return EpubContent(
      html: html,
      css: css,
      images: images,
      fonts: fonts,
      allFiles: allFiles,
    );
  }

  static Future<Map<String, EpubByteContentFile>> readByteContentFiles(
    Map<String, EpubByteContentFileRef> byteContentFileRefs,
  ) async {
    final result = <String, EpubByteContentFile>{};

    await Future.forEach(byteContentFileRefs.keys, (String key) async {
      final fileRef = byteContentFileRefs[key];
      if (fileRef != null) {
        result[key] = await readByteContentFile(fileRef);
      }
    });

    return result;
  }

  static Future<EpubByteContentFile> readByteContentFile(
    EpubContentFileRef contentFileRef,
  ) async =>
      EpubByteContentFile(
        fileName: contentFileRef.fileName,
        contentType: contentFileRef.contentType,
        contentMimeType: contentFileRef.contentMimeType,
        content: await contentFileRef.readContentAsBytes(),
      );

  static Future<Map<String, EpubTextContentFile>> readTextContentFiles(
    Map<String, EpubTextContentFileRef> textContentFileRefs,
  ) async {
    final result = <String, EpubTextContentFile>{};

    await Future.forEach(textContentFileRefs.keys, (String key) async {
      final value = textContentFileRefs[key];
      if (value != null) {
        result[key] = EpubTextContentFile(
          fileName: value.fileName,
          contentType: value.contentType,
          contentMimeType: value.contentMimeType,
          content: await value.readContentAsText(),
        );
      }
    });
    return result;
  }

  static Future<List<EpubChapter>> readChapters(
    List<EpubChapterRef> chapterRefs,
  ) async {
    final result = <EpubChapter>[];
    await Future.forEach(chapterRefs, (EpubChapterRef chapterRef) async {
      result.add(
        EpubChapter(
          title: chapterRef.title,
          contentFileName: chapterRef.contentFileName,
          anchor: chapterRef.anchor,
          htmlContent: await chapterRef.readHtmlContent(),
          subChapters: await readChapters(chapterRef.subChapters ?? []),
        ),
      );
    });
    return result;
  }
}
