import 'package:dotenv/dotenv.dart';
import 'package:flutter_test/flutter_test.dart';


void main() => test('Check env variables availability', () {
  final env = DotEnv()..load();

  final url = env['API_URL'];
  final key = env['API_KEY'];

  expect(url, isNotNull);
  expect(key, isNotNull);
});
