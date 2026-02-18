import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_head_meta.dart';
import 'package:equatable/equatable.dart';

class EpubNavigationHead extends Equatable {
  const EpubNavigationHead({
    this.metadata,
  });

  final List<EpubNavigationHeadMeta>? metadata;

  @override
  List<Object?> get props => [
    metadata,
  ];

  @override
  String toString() {
    return 'EpubNavigationHead{Metadata: $metadata}';
  }

  EpubNavigationHead copyWith({
    List<EpubNavigationHeadMeta>? metadata,
  }) {
    return EpubNavigationHead(
      metadata: metadata ?? this.metadata,
    );
  }
}
