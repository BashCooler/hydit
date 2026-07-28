import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/utils/utils.dart';

import 'executor.dart';
import 'models.dart';


extension PickResult on Future<Result<String>> {

  Future<Result<Pick>> pick([
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
    return map((json) {
      return json.pick(
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
    });
  }
}


extension PickAs on Future<Result<Pick>> {

  Future<Result<List<T>>> asListOrThrow<T>(
    T Function(RequiredPick) map, {
    T Function(Pick pick)? whenNull,
  }) async {
    final result = await this;

    if (result is Failure<Pick>) {
      return Failure.from(result);
    }

    return result
        .unwrapOrThrow()
        .asListOrThrow(map, whenNull: whenNull)
        .toSuccess();
  }

  Future<Result<Map<K, V>>> asMapOrThrow<K, V>() async {
    final result = await this;

    if (result is Failure<Pick>) {
      return Failure.from(result);
    }

    return result
        .unwrapOrThrow().asMapOrThrow<K, V>()
        .toSuccess();
  }
}
