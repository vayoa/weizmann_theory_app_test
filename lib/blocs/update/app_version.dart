import 'package:pub_semver/pub_semver.dart';
import 'package:weizmann_theory_app_test/blocs/update/old_version.dart';
import 'package:weizmann_theory_app_test/utilities.dart';

class AppVersion extends Comparable<AppVersion> with Compared<AppVersion> {
  late final Version version;
  late final String? releaseNotes;
  late final String? downloadUrl;

  /// Parse [v] to a [Version], supports [OldVersion]...
  static Version parseWithOld(String v) {
    try {
      return Version.parse(v);
    } catch (e) {
      return OldVersion.parse(v).toSemantic();
    }
  }

  AppVersion.empty() {
    version = Version.none;
    releaseNotes = null;
    downloadUrl = null;
  }

  AppVersion.parse(String v) {
    version = parseWithOld(v);
    releaseNotes = null;
    downloadUrl = null;
  }

  AppVersion.fromJson(Map<String, dynamic> json) {
    version = parseWithOld(json["tag_name"]);
    releaseNotes = json["body"];
    downloadUrl = json["assets"][0]["browser_download_url"];
  }

  @override
  int compareTo(AppVersion other) => version.compareTo(other.version);

  bool get beta => version.isPreRelease;

  @override
  String toString() => 'v${version.canonicalizedVersion}';
}
