import 'package:get/get.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';


class Images extends GetxController {
  final images = <HydrusImage>[].obs;

  RxList<HydrusImage> get $ => images;
}