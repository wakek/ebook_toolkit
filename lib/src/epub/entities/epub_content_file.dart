import 'package:ebook_toolkit/src/epub/entities/epub_content_type.dart';
import 'package:equatable/equatable.dart';

abstract class EpubContentFile extends Equatable {
  const EpubContentFile({
    this.fileName,
    this.contentType,
    this.contentMimeType,
  });

  final String? fileName;
  final EpubContentType? contentType;
  final String? contentMimeType;

  @override
  List<Object?> get props => [fileName, contentType, contentMimeType];
}
