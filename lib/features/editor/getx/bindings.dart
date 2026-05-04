import 'package:get/get.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';

import 'tags.dart';


class EditorBindings extends Bindings {
  final String tag;

  EditorBindings({required this.tag});

  @override
  void dependencies() {
    Get.put(QueryController(), tag: tag);

    final PageGetxController page = Get.find(tag: tag);
    final Images images = Get.find();
    Get.put(TagManager()..init(images[page.i].service));
  }
}