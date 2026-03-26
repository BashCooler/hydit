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
    if (tag.diff == .add) {
      tag.diff = null;
      tags.remove(tag);
      tagsToAdd.remove(tag);
      update();
      return;
    }
    tag.diff = Diff.add;
    tags.addIf(!tags.contains(tag), tag);
    tagsToAdd.addIf(!tagsToAdd.contains(tag), tag);
    update();
  }

  void delete(Tag tag) {
    if (tagsToDelete.contains(tag)) {
      tag.diff = null;
      tagsToDelete.remove(tag);
    } else if (tag.diff == null) {
      tag.diff = Diff.delete;
      tagsToDelete.add(tag);
    } else if (tag.diff == .add) {
      tag.diff = null;
      tags.remove(tag);
      tagsToAdd.remove(tag);
    }
    update();
  }
}