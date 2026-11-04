import 'package:get/get.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/services/services.dart';


class Repo() {
  final HydrusApi api = Get.find<Storage>().api();
}
