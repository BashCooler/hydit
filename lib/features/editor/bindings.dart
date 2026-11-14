import 'package:get/get.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/features/search/getx/tag_search.dart';

import 'getx/base.dart';
import 'getx/batch.dart';
import 'getx/single.dart';


class EditorBindings({
  required final TagManager manager,
}) extends Bindings {
  final tag = 'Editor'.unique();

  final search = TagSearchController();

  factory paged({
    required PageGetxController page,
    String? service,
  }) {
    final manager = PagedTagManager(page: page, service: service);
    return EditorBindings(manager: manager);
  }

  factory batch({
    required List<HydrusFile> files,
  }) {
    final manager = BatchTagManager(files: files);
    return EditorBindings(manager: manager);
  }

  @override
  void dependencies() {
    Get.put(search, tag: tag);
    Get.put(manager, tag: tag);
  }
}
