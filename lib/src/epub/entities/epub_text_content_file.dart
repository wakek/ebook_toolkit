import 'package:ebook_toolkit/src/epub/entities/epub_content_file.dart';

class EpubTextContentFile extends EpubContentFile {
  const EpubTextContentFile({
    super.fileName,
    super.contentType,
    super.contentMimeType,
    this.content,
  });

  final String? content;

  @override
  List<Object?> get props => [
    ...super.props,
    content,
  ];
}
