import 'package:flutter_test/flutter_test.dart';

import 'package:hydit/utils/get.dart';


void main() => test('Test actions', () {
  //
  final action = Action<int>();

  expect(action.length, equals(0));

  action + f1;

  expect(action.length, equals(1));

  action + f1;

  expect(action.length, equals(1));

  action + f2;

  expect(action.length, equals(2));

  action - f1 - f2;

  expect(action.length, equals(0));

  action + f1 + f2;

  expect(action.length, equals(2));

  action.clear();

  expect(action.length, 0);
});

void f1(int n) {}

void f2(int n) {}
