class ZipPathUtils {
  factory ZipPathUtils() {
    return _singleton;
  }

  ZipPathUtils._internal();

  static final ZipPathUtils _singleton = ZipPathUtils._internal();

  static ZipPathUtils get instance => _singleton;

  String getDirectoryPath(String filePath) {
    final lastSlashIndex = filePath.lastIndexOf('/');

    if (lastSlashIndex == -1) {
      return '';
    } else {
      return filePath.substring(0, lastSlashIndex);
    }
  }

  static String? combine(String? directory, String? fileName) {
    if (directory == null || directory == '') {
      return fileName;
    } else {
      return '$directory/${fileName!}';
    }
  }
}
