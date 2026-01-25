import 'package:ebook_toolkit/src/epub/schema/opf/epub_manifest_item.dart';
import 'package:equatable/equatable.dart';

class EpubManifest extends Equatable {
  const EpubManifest({
    this.items,
  });

  final List<EpubManifestItem>? items;

  @override
  List<Object?> get props => [
    items,
  ];

  @override
  String toString() {
    return 'EpubManifest{items: $items}';
  }
}
