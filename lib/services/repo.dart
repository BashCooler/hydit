import 'package:get/get.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/services/services.dart';


class Repo() {
  final HydrusApi api = Get.find<Storage>().api();

  TagRelationService get relations => Get.find();

  Future<Result<void>> download(int id) =>
      api.getFile(id).then(Native.saveFile).run();
}
