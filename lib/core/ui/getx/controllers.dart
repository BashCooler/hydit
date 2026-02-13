import 'package:get/get.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';


class SearchVisibility extends GetxController {
  var visible = true.obs;
  void show() => visible.value = true;
  void hide() => visible.value = false;
}


class Images extends GetxController {
  final images = <HydrusImage>[].obs;
}