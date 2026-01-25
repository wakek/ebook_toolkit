import 'package:equatable/equatable.dart';

class EpubChapter extends Equatable {
  const EpubChapter({
    this.title,
    this.contentFileName,
    this.anchor,
    this.htmlContent,
    this.subChapters,
  });

  final String? title;
  final String? contentFileName;
  final String? anchor;
  final String? htmlContent;
  final List<EpubChapter>? subChapters;

  @override
  List<Object?> get props => [
    title,
    contentFileName,
    anchor,
    htmlContent,
    subChapters,
  ];

  @override
  String toString() {
    return 'Title: $title, Subchapter count: ${subChapters!.length}';
  }
}
