import 'package:equatable/equatable.dart';

class EpubNavigationDocTitle extends Equatable {
  const EpubNavigationDocTitle({
    this.titles,
  });

  final List<String>? titles;

  @override
  List<Object?> get props => [
    titles,
  ];

  EpubNavigationDocTitle copyWith({
    List<String>? titles,
  }) {
    return EpubNavigationDocTitle(
      titles: titles ?? this.titles,
    );
  }
}
