import 'package:flutter_test/flutter_test.dart';

import 'package:hydit/utils/url.dart';
import 'package:hydit/services/executor/executor.dart';


void main() {
  test('URL validation', () {

    final ipV4 = {
      'http://127.0.0.1': true,
      'http://127.0.0.1:45869': true,
      'https://127.0.0.1': true,
      'https://127.0.0.1:45869': true,
      'https://127.0.0.1:45869/api_version/': false,
      '127.0.0.1': false,
      '256.0.0.1': false,
      '192.256.0.1': false,
      '192.168.256.1': false,
      '192.168.0.256': false,
    };

    final ipV6 = {
      'http://[::]': true,
      'http://[::1]:45869': true,
      'https://[2001:db8::1]': true,
      '[::1]': false,
    };

    final local = {
      'http://localhost': true,
      'http://localhost:45869': true,
      'http://hydrus.local': true,
      'http://nas': true,
      'http://my-server': true,
      'http://my-server.local': true,
      'http://nas.home.example': true,
      'localhost': false,
    };

    final domainNames = {
      'http://domain.com': true,
      'https://domain.com': true,
      'http://domain.com:45869': true,
      'https://domain.com:45869': true,
      'http://subdomain.domain.com': true,
      'https://subdomain.domain.com': true,
      'http://subdomain.domain.com:45869': true,
      'https://subdomain.domain.com:45869': true,
      'subdomain.domain.com': false,
    };

    final scheme = {
      'ftp://example.com' : false,
      'file:///tmp/file': false,
    };

    final noHost = {
      'http://': false,
      'https://': false,
    };

    final typos = {
      'http:/example.com': false,
      'https//example.com': false,
      '://example.com': false,
    };

    final urls = <String, bool>{
      ...ipV4,
      ...ipV6,
      ...local,
      ...domainNames,
      ...scheme,
      ...noHost,
      ...typos,
    };

    for (final MapEntry(key: url, value: isValid) in urls.entries) {
      final result = parseUrl(url) is Success;

      expect(result, equals(isValid), reason: url);
    }
  });
}
