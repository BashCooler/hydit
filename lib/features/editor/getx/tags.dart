import 'package:get/get.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';


class TagManager extends GetxController {
  // TODO convert to <TagService, Tag>
  final tags = <Tag>[].obs;
  final tagsToAdd = <Tag>[].obs;
  final tagsToDelete = <Tag>[].obs;

  int get additions => tagsToAdd.length;
  int get deletions => tagsToDelete.length;

  void add(Tag tag) {
    // TODO add to tags list
    tagsToAdd.addIf(!tagsToAdd.contains(tag), tag);
  }

  void delete(Tag tag) {
    if (tagsToDelete.contains(tag)) {
      // TODO remove from tags list
      tagsToDelete.remove(tag);
    } else {
      tagsToDelete.add(tag);
    }
  }
}