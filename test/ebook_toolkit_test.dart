import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_toolkit/ebook_toolkit.dart';
import 'package:ebook_toolkit/src/ebook_toolkit_platform_interface.dart';
import 'package:ebook_toolkit/src/ebook_toolkit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEbookToolkitPlatform
    with MockPlatformInterfaceMixin
    implements EbookToolkitPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EbookToolkitPlatform initialPlatform = EbookToolkitPlatform.instance;

  test('$MethodChannelEbookToolkit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEbookToolkit>());
  });

  test('getPlatformVersion', () async {
    EbookToolkit ebookToolkitPlugin = EbookToolkit();
    MockEbookToolkitPlatform fakePlatform = MockEbookToolkitPlatform();
    EbookToolkitPlatform.instance = fakePlatform;

    expect(await ebookToolkitPlugin.getPlatformVersion(), '42');
  });
}
