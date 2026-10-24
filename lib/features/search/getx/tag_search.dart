import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/api/models.dart';
import 'package:hydit/services/services.dart';


class TagSearchController extends GetxController {
  final suggests = <TagDto>[].obs;

  final _suggestVisible = false.obs;

  final controller = TextEditingController();

  bool get suggestsVisible => _suggestVisible.value;

  Repo get repo => Get.find();

  String get text => controller.text;

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

    final tags = await repo.api
        .getSearchTags(q, tagDisplayType: .display)
        .run()
        .getOrNull();

    if (id != _requestId || tags == null) return;

    suggests.assignAll(tags.take(15));

    _suggestVisible.value = true;
  }

  void clear() {
    _suggestVisible.value = false;
    controller.text = '';
    suggests.clear();
  }
}