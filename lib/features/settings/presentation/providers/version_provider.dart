import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'version_provider.g.dart';

@riverpod
Future<String> version(VersionRef ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return 'v${packageInfo.version} (${packageInfo.buildNumber})';
}
