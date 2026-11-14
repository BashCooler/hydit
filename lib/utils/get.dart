import 'package:get/get.dart';


S? maybeFind<S>({String? tag}) {
  return Get.isRegistered<S>(tag: tag)
      ? Get.find<S>(tag: tag)
      : null;
}


extension ToRx<T> on T {
  Rx<T> get rx => Rx<T>(this);
}
