import 'package:ebook_toolkit/src/epub/schema/navigation/epub_metadata.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_label.dart';
import 'package:equatable/equatable.dart';

class EpubNavigationPoint extends Equatable {
  const EpubNavigationPoint({
    this.id,
    this.navigationClass,
    this.playOrder,
    this.navigationLabels,
    this.content,
    this.childNavigationPoints,
  });

  final String? id;
  final String? navigationClass;
  final String? playOrder;
  final List<EpubNavigationLabel>? navigationLabels;
  final EpubNavigationContent? content;
  final List<EpubNavigationPoint>? childNavigationPoints;

  @override
  List<Object?> get props => [
    id,
    navigationClass,
    playOrder,
    navigationLabels,
    content,
    childNavigationPoints,
  ];

  @override
  String toString() {
    return 'Id: $id, Content.Source: ${content!.source}';
  }

  EpubNavigationPoint copyWith({
    String? id,
    String? navigationClass,
    String? playOrder,
    List<EpubNavigationLabel>? navigationLabels,
    EpubNavigationContent? content,
    List<EpubNavigationPoint>? childNavigationPoints,
  }) {
    return EpubNavigationPoint(
      id: id ?? this.id,
      navigationClass: navigationClass ?? this.navigationClass,
      playOrder: playOrder ?? this.playOrder,
      navigationLabels: navigationLabels ?? this.navigationLabels,
      content: content ?? this.content,
      childNavigationPoints:
          childNavigationPoints ?? this.childNavigationPoints,
    );
  }
}
