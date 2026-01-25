import 'dart:async';

import 'package:archive/archive.dart';
import 'package:ebook_toolkit/src/epub/entities/epub_schema.dart';
import 'package:ebook_toolkit/src/epub/readers/navigation_reader.dart';
import 'package:ebook_toolkit/src/epub/readers/package_reader.dart';
import 'package:ebook_toolkit/src/epub/readers/root_file_path_reader.dart';
import 'package:ebook_toolkit/src/utils/zip_path_utils.dart';

class SchemaReader {
  factory SchemaReader() {
    return _singleton;
  }

  SchemaReader._internal();

  static final SchemaReader _singleton = SchemaReader._internal();

  static SchemaReader get instance => _singleton;

  Future<EpubSchema> readSchema(Archive epubArchive) async {
    final rootFilePath = (await RootFilePathReader().getRootFilePath(
      epubArchive,
    ))!;

    final contentDirectoryPath = ZipPathUtils.instance.getDirectoryPath(
      rootFilePath,
    );

    final package = await PackageReader().readPackage(
      epubArchive,
      rootFilePath,
    );

    final navigation = await NavigationReader().readNavigation(
      epubArchive,
      contentDirectoryPath,
      package,
    );

    return EpubSchema(
      package: package,
      navigation: navigation,
      contentDirectoryPath: contentDirectoryPath,
    );
  }
}
