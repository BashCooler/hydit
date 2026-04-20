import 'package:get/get.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';


class Images extends GetxController {
  final images = <HydrusImage>[].obs;

  int get length => images.length;
  HydrusImage operator [](int index) => images[index];

  void assignAll(Iterable<HydrusImage> items) => images.assignAll(items);
}