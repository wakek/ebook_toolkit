import 'package:ebook_toolkit/src/epub/schema/opf/epub_spine_item_ref.dart';
import 'package:equatable/equatable.dart';

class EpubSpine extends Equatable {
  const EpubSpine({
    this.tableOfContents,
    this.items,
    this.ltr,
  });

  final String? tableOfContents;
  final List<EpubSpineItemRef>? items;
  final bool? ltr;

  @override
  List<Object?> get props => [tableOfContents, ltr, ...items ?? []];

  EpubSpine copyWith({
    String? tableOfContents,
    List<EpubSpineItemRef>? items,
    bool? ltr,
  }) {
    return EpubSpine(
      tableOfContents: tableOfContents ?? this.tableOfContents,
      items: items ?? this.items,
      ltr: ltr ?? this.ltr,
    );
  }
}
