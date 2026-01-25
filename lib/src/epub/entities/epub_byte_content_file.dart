import 'package:ebook_toolkit/src/epub/entities/epub_content_file.dart';

class EpubByteContentFile extends EpubContentFile {
  const EpubByteContentFile({
    super.fileName,
    super.contentType,
    super.contentMimeType,
    this.content,
  });

  final List<int>? content;

  @override
  List<Object?> get props => [
    ...super.props,
    content,
  ];
}
