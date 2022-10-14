import 'package:flutter_test/flutter_test.dart';
import 'package:weizmann_theory_app_test/blocs/update/version.dart';

main() {
  test('.compareTo()', () {
    // Less Than
    expect(_parse("0.8.0"), lessThan(_parse("0.8.1")));
    expect(_parse("0.8.0.1"), lessThan(_parse("0.8.1")));
    expect(_parse("0.8.0.1"), lessThan(_parse("0.8.0.2")));
    expect(_parse("0.6"), lessThan(_parse("0.7.0")));
    expect(_parse("1.6.1"), lessThan(_parse("2.6.1")));
    expect(_parse("0.8.0.3-b"), lessThan(_parse("0.8.0.3")));
    expect(_parse("0.8.0.9-b"), lessThan(_parse("0.8.0.10-b")));
    expect(_parse("0.8.0.9-b"), lessThan(_parse("0.8.0.11-b")));
    expect(_parse("0.8.0.10-b"), lessThan(_parse("0.8.0.11-b")));
    // Equals
    expect(_parse("0.8.0"), equals(_parse("0.8.0")));
    expect(_parse("0.8.0"), equals(_parse("0.8")));
    // Greater Than
    expect(_parse("0.8.1"), greaterThan(_parse("0.3.1")));
    expect(_parse("1.9.3"), greaterThan(_parse("1.9.2")));
  });
}

Version _parse(String v) => Version.parse(v);
