import 'package:deep_pick/deep_pick.dart';

import 'models.dart';


extension PickExtension on String {

  Pick pick([
    Object? arg0,
    Object? arg1,
    Object? arg2,
    Object? arg3,
    Object? arg4,
    Object? arg5,
    Object? arg6,
    Object? arg7,
    Object? arg8,
    Object? arg9,
  ]) {
    return pickFromJson(
      this,
      arg0,
      arg1,
      arg2,
      arg3,
      arg4,
      arg5,
      arg6,
      arg7,
      arg8,
      arg9,
    );
  }
}


extension PickResult on Result<String> {

  Result<Pick> pick([
    Object? arg0,
    Object? arg1,
    Object? arg2,
    Object? arg3,
    Object? arg4,
    Object? arg5,
    Object? arg6,
    Object? arg7,
    Object? arg8,
    Object? arg9,
  ]) {
    return map(
      (json) => pickFromJson(
        json,
        arg0,
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
        arg7,
        arg8,
        arg9,
      ),
    );
  }
}


extension PickAs on Result<Pick> {

  Result<List<T>> asListOrThrow<T>(T Function(RequiredPick) map, {
    T Function(Pick pick)? whenNull,
  }) {
    final result = this;

    if (result is Failure<Pick>) {
      return Failure.from(result);
    }

    return result
        .getOrThrow()
        .asListOrThrow(map, whenNull: whenNull)
        .toSuccess();
  }

  Result<Map<K, V>> asMapOrThrow<K, V>() {
    final result = this;

    if (result is Failure<Pick>) {
      return Failure.from(result);
    }

    return result
        .getOrThrow().asMapOrThrow<K, V>()
        .toSuccess();
  }
}
