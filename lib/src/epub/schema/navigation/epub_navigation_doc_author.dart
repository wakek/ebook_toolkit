import 'package:equatable/equatable.dart';

class EpubNavigationDocAuthor extends Equatable {
  const EpubNavigationDocAuthor({
    this.authors,
  });

  final List<String>? authors;

  @override
  List<Object?> get props => [
    authors,
  ];

  EpubNavigationDocAuthor copyWith({
    List<String>? authors,
  }) {
    return EpubNavigationDocAuthor(
      authors: authors ?? this.authors,
    );
  }
}
