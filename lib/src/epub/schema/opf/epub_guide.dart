import 'package:ebook_toolkit/src/epub/schema/opf/epub_guide_reference.dart';
import 'package:equatable/equatable.dart';

class EpubGuide extends Equatable {
  const EpubGuide({
    this.items,
  });

  final List<EpubGuideReference>? items;

  @override
  List<Object?> get props => [
    items,
  ];
}
