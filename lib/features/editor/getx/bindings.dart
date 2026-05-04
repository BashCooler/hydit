import 'package:get/get.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';


class EditorBindings extends Bindings {
  final String tag;

  EditorBindings({required this.tag});

  @override
  void dependencies() {
    Get.put(QueryController(), tag: tag);
  }
}