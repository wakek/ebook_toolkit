import 'package:ebook_toolkit/src/epub/entities/epub_byte_content_file.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_content_file.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_text_content_file.dart';
import 'package:equatable/equatable.dart';

class EpubContent extends Equatable {
  const EpubContent({
    this.html = const <String, EpubTextContentFile>{},
    this.css = const <String, EpubTextContentFile>{},
    this.images = const <String, EpubByteContentFile>{},
    this.fonts = const <String, EpubByteContentFile>{},
    this.allFiles = const <String, EpubContentFile>{},
  });

  final Map<String, EpubTextContentFile>? html;
  final Map<String, EpubTextContentFile>? css;
  final Map<String, EpubByteContentFile>? images;
  final Map<String, EpubByteContentFile>? fonts;
  final Map<String, EpubContentFile>? allFiles;

  @override
  List<Object?> get props => [
    html,
    css,
    images,
    fonts,
    allFiles,
  ];
}
