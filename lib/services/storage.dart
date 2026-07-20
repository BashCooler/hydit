import 'package:hive_ce_flutter/adapters.dart';


abstract class Storage {
  T? get<T>(String key);

  void put<T>(String key, T value);
}


class HiveStorage extends Storage {

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


extension Or<T> on T? {

  T or(T value) => this ?? value;
}
