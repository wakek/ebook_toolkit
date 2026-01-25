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
}
