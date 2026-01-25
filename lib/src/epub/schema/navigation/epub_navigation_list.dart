import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_label.dart';
import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_target.dart';
import 'package:equatable/equatable.dart';

class EpubNavigationList extends Equatable {
  const EpubNavigationList({
    this.id,
    this.navigationClass,
    this.navigationLabels,
    this.navigationTargets,
  });

  final String? id;
  final String? navigationClass;
  final List<EpubNavigationLabel>? navigationLabels;
  final List<EpubNavigationTarget>? navigationTargets;

  @override
  List<Object?> get props => [
    id,
    navigationClass,
    navigationLabels,
    navigationTargets,
  ];

  @override
  String toString() {
    return 'EpubNavigationList{id: $id, navigationClass: $navigationClass, navigationLabels: $navigationLabels, navigationTargets: $navigationTargets}';
  }

  EpubNavigationList copyWith({
    String? id,
    String? navigationClass,
    List<EpubNavigationLabel>? navigationLabels,
    List<EpubNavigationTarget>? navigationTargets,
  }) {
    return EpubNavigationList(
      id: id ?? this.id,
      navigationClass: navigationClass ?? this.navigationClass,
      navigationLabels: navigationLabels ?? this.navigationLabels,
      navigationTargets: navigationTargets ?? this.navigationTargets,
    );
  }
}
