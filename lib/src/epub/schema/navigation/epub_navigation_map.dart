import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation_point.dart';
import 'package:equatable/equatable.dart';

class EpubNavigationMap extends Equatable {
  const EpubNavigationMap({
    this.points,
  });

  final List<EpubNavigationPoint>? points;

  @override
  List<Object?> get props => [
    points,
  ];

  @override
  String toString() {
    return 'EpubNavigationMap{points: $points}';
  }
}
