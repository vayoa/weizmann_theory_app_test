import 'dart:math';

import 'package:pub_semver/pub_semver.dart';

import '../../utilities.dart';

// TODO: Delete this file after a version update.
@Deprecated('Use AppVersion instead')
class OldVersion extends Comparable<OldVersion> with Compared<OldVersion> {
  late final String number;
  late final bool beta;
  late final String? releaseNotes;
  late final String? downloadUrl;

  static const int maxNumbers = 4;

  OldVersion(this.number, this.beta, {this.releaseNotes, this.downloadUrl});

  // TODO: Optimize...
  String _parseNumber(String v) {
    if (v.startsWith('v')) v = v.substring(1);
    final list = _list(v);
    for (int i = list.length; i < maxNumbers; i++) {
      list.add(0);
    }
    var s = '${list.first}';
    for (int i = 1; i < maxNumbers; i++) {
      s += '.${list[i]}';
    }
    return s;
  }

  OldVersion.parse(String v) {
    final parts = v.split('-');
    number = _parseNumber(parts[0]);
    beta = parts.length > 1 && parts[1].startsWith('b');
  }

  /// Parses an [OldVersion] from the github releases api.
  OldVersion.fromJson(Map<String, dynamic> json) {
    final temp = OldVersion.parse(json["tag_name"]);
    number = _parseNumber(temp.number);
    beta = json["prerelease"];
    releaseNotes = json["body"];
    downloadUrl = json["assets"][0]["browser_download_url"];
  }

  @override
  int compareTo(OldVersion other) {
    final c = _list(number), o = _list(other.number);
    final maxL = min(c.length, o.length);
    for (int i = 0; i < maxL; i++) {
      final r = c[i].compareTo(o[i]);
      if (r != 0) return r;
    }
    final compareTo = c.length.compareTo(o.length);
    if (compareTo == 0) {
      if (beta && !other.beta) {
        return -1;
      } else if (!beta && other.beta) {
        return 1;
      }
    }
    return compareTo;
  }

  List<int> _list(String number) =>
      number.split('.').map((e) => int.parse(e)).toList();

  Version toSemantic() {
    final l = _list(number);
    while (l.length < maxNumbers) {
      l.add(0);
    }
    return Version(
      l[0],
      l[1],
      l[2],
      build: l[3].toString(),
      pre: beta ? 'b' : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OldVersion && compareTo(other) == 0;

  @override
  int get hashCode => number.hashCode ^ beta.hashCode;

  @override
  String toString() => 'v$number${beta ? '-b' : ''}';
}
