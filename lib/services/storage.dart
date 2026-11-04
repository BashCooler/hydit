import 'package:hive_ce_flutter/adapters.dart';
import 'package:hydit/api/api.dart';


abstract class const Storage() {
  T? get<T>(String key);

  void put<T>(String key, T value);

  Api api() => Api(
    url: get('url') ?? '',
    key: get('key') ?? '',
  );
}


class const HiveStorage() extends Storage {

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('settings');
  }

  static Box get box => Hive.box('settings');

  @override
  T? get<T>(String key) => box.get(key);

  @override
  void put<T>(String key, T value) => box.put(key, value);
}
