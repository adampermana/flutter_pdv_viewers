// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_pdv_viewers/flutter_pdv_viewers.dart';
// import 'package:flutter_pdv_viewers/flutter_pdv_viewers_platform_interface.dart';
// import 'package:flutter_pdv_viewers/flutter_pdv_viewers_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
//
// class MockFlutterPdvViewersPlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterPdvViewersPlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }
//
// void main() {
//   final FlutterPdvViewersPlatform initialPlatform = FlutterPdvViewersPlatform.instance;
//
//   test('$MethodChannelFlutterPdvViewers is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelFlutterPdvViewers>());
//   });
//
//   test('getPlatformVersion', () async {
//     FlutterPdvViewers flutterPdvViewersPlugin = FlutterPdvViewers();
//     MockFlutterPdvViewersPlatform fakePlatform = MockFlutterPdvViewersPlatform();
//     FlutterPdvViewersPlatform.instance = fakePlatform;
//
//     expect(await flutterPdvViewersPlugin.getPlatformVersion(), '42');
//   });
// }
