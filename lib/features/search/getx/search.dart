import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/services/repo.dart';
import 'package:hydit/services/mapper.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/tag.dart';


class TagSearchController extends GetxController {
  final suggests = <Tag>[].obs;
  final _suggestVisible = false.obs;

  final Repo repo = Get.find();
  final controller = TextEditingController();

  bool get suggestsVisible => _suggestVisible.value;

  String get text => controller.text;
  TextEditingController get $ => controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
        .getSearchTags(q)
        .run()
        .unwrap();
    if (id != _requestId || response == null) return;

    final List<Tag> parsed = Mapper.parseSearchResults(response);

    suggests.assignAll(parsed);

    _suggestVisible.value = true;
  }

  void clear() {
    _suggestVisible.value = false;
    controller.text = '';
    suggests.clear();
  }
}