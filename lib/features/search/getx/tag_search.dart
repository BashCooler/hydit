import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/services.dart';


class TagSearchController extends GetxController {
  final suggests = <Tag>[].obs;
  final _suggestVisible = false.obs;

  final Repo repo = Get.find();
  final controller = TextEditingController();

  bool get suggestsVisible => _suggestVisible.value;

  String get text => controller.text;
  TextEditingController get $ => controller;

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }

  void query(String query) {
    switch (query.length) {
      case < 3:
        suggests.clear();
        _suggestVisible.value = false;
      case _:
        fetch(query);
    }
  }

  int _requestId = 0;

  Future<void> fetch(String q) async {
    final int id = ++_requestId;

    final response = await repo.api
        .getSearchTags(q, tagDisplayType: .display)
        .run();

    if (id != _requestId || response is Failure) return;

    final tags = response
        .getOrThrow()
        .pick('tags')
        .asListOrThrow(Tag.fromPick)
        .take(15);

    suggests.assignAll(tags);

    _suggestVisible.value = true;
  }

  void clear() {
    _suggestVisible.value = false;
    controller.text = '';
    suggests.clear();
  }
}