import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:weizmann_theory_app_test/blocs/update/app_version.dart';

main() {
  test('parseWithOld()', () {
    expect(_parse('v0.8.0-b+12'), Version(0, 8, 0, pre: 'b', build: '12'));
  });
}

_parse(String v) => AppVersion.parseWithOld(v);
