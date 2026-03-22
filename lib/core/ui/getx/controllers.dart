import 'package:get/get.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';


class Images extends GetxController {
  final images = <HydrusImage>[].obs;

  RxList<HydrusImage> get $ => images;
}