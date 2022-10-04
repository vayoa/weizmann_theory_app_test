import 'dart:math';

import '../../utilities.dart';

class Version extends Comparable<Version> with Compared<Version> {
  late final String number;
  late final bool beta;
  late final String? releaseNotes;
  late final String? downloadUrl;

  Version(this.number, this.beta, {this.releaseNotes, this.downloadUrl});

  // TODO: Optimize...
  String _parseNumber(String v) {
    if (v.startsWith('v')) v = v.substring(1);
    final list = _list(v);
    for (int i = list.length; i < 3; i++) {
      list.add(0);
    }
    var s = '${list.first}';
    for (int i = 1; i < 3; i++) {
      s += '.${list[i]}';
    }
    return s;
  }

  Version.parse(String v) {
    final parts = v.split('-');
    number = _parseNumber(v);
    beta = parts.length > 1 && parts[1].startsWith('b');
  }

  /// Parses a [Version] from the github releases api.
  Version.fromJson(Map<String, dynamic> json) {
    final temp = Version.parse(json["tag_name"]);
    number = _parseNumber(temp.number);
    beta = json["prerelease"];
    releaseNotes = json["body"];
    downloadUrl = json["assets"][0]["browser_download_url"];
  }

  @override
  int compareTo(Version other) {
    final c = _list(number), o = _list(other.number);
    final maxL = min(c.length, o.length);
    for (int i = 0; i < maxL; i++) {
      final r = c[i].compareTo(o[i]);
      if (r != 0) return r;
    }
    return c.length.compareTo(o.length);
  }

  List<int> _list(String number) =>
      number.split('.').map((e) => int.parse(e)).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Version && compareTo(other) == 0;

  @override
  int get hashCode => number.hashCode ^ beta.hashCode;

  @override
  String toString() => 'v$number${beta ? '-b' : ''}';
}
