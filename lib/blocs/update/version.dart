import 'dart:math';

import '../../utilities.dart';

class Version extends Comparable<Version> with Compared<Version> {
  late final String number;
  late final bool beta;
  late final String? releaseNotes;
  late final String? downloadUrl;

  Version(this.number, this.beta, {this.releaseNotes, this.downloadUrl});

  Version.parse(String v) {
    final parts = v.split('-');
    number = parts[0].startsWith('v') ? parts[0].substring(1) : parts[0];
    beta = parts[1].startsWith('b');
  }

  /// Parses a [Version] from the github releases api.
  Version.fromJson(Map<String, dynamic> json) {
    final temp = Version.parse(json["tag_name"]);
    number = temp.number;
    beta = json["prerelease"];
    releaseNotes = json["body"];
    downloadUrl = json["assets"][0]["browser_download_url"];
  }

  @override
  int compareTo(Version other) {
    final c = _list, o = other._list;
    final maxL = min(c.length, o.length);
    for (int i = 0; i < maxL; i++) {
      final r = c[i].compareTo(o[i]);
      if (r != 0) return r;
    }
    return c.length.compareTo(o.length);
  }

  List<int> get _list =>
      number.split('.').map((e) => int.parse(e)).toList(growable: false);

  @override
  String toString() => 'v$number${beta ? '-b' : ''}';
}
