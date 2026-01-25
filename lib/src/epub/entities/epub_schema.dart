import 'package:ebook_toolkit/src/epub/schema/navigation/epub_navigation.dart';
import 'package:ebook_toolkit/src/epub/schema/opf/epub_package.dart';
import 'package:equatable/equatable.dart';

class EpubSchema extends Equatable {
  const EpubSchema({
    this.package,
    this.navigation,
    this.contentDirectoryPath,
  });

  final EpubPackage? package;
  final EpubNavigation? navigation;
  final String? contentDirectoryPath;

  @override
  List<Object?> get props => [
    package,
    navigation,
    contentDirectoryPath,
  ];
}
