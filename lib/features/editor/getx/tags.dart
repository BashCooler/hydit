import 'package:get/get.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';


class TagManager extends GetxController {
  final tagsToAdd = <Tag>{}.obs;
  final tagsToRemove = <Tag>{}.obs;

  int get additions => tagsToAdd.length;
  int get deletions => tagsToRemove.length;

  void add(Tag tag) {
    tagsToAdd.add(tag);
  }
}