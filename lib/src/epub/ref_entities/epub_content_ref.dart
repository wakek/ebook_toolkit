import 'package:ebook_toolkit/src/epub/ref_entities/epub_byte_content_file_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_content_file_ref.dart';
import 'package:ebook_toolkit/src/epub/ref_entities/epub_text_content_file_ref.dart';
import 'package:equatable/equatable.dart';

class EpubContentRef extends Equatable {
  const EpubContentRef({
    this.html,
    this.css,
    this.images,
    this.fonts,
    this.allFiles,
  });

  final Map<String, EpubTextContentFileRef>? html;
  final Map<String, EpubTextContentFileRef>? css;
  final Map<String, EpubByteContentFileRef>? images;
  final Map<String, EpubByteContentFileRef>? fonts;
  final Map<String, EpubContentFileRef>? allFiles;

  @override
  List<Object?> get props => [
    html,
    css,
    images,
    fonts,
    allFiles,
  ];
}
