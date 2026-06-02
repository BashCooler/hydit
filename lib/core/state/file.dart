import 'package:get/get.dart';

import '../entity/metadata.dart';
import '../services/repo.dart';


class HydrusFile {
  final int id;
  final metadata = Rxn<FileMetadata>();

  HydrusFile({required this.id});

  bool get loaded => metadata.value != null;
  bool get loading => metadata.value == null;

  Future<void> forceLoadMetadata() async {
    if (loaded) return;
    final Repo repo = Get.find();
    await repo.setMetadataFor(this);
  }

  FileMetadata? get meta => metadata.value;
}