import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/core/data/api.dart';
import 'package:hydrus_flutter/core/data/mapper.dart';
import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';


class QueryController extends GetxController {
  final query = ''.obs;
  final suggests = <Tag>[].obs;
  final _tags = <Tag>[].obs;
  final isLoading = false.obs;
  final _suggestVisible = false.obs;
  final badgeVisible = true.obs;

  List<Tag> get tags => _tags;
  String get text => textController.text;
  TextEditingController get $ => textController;
  bool get suggestsVisible => _suggestVisible.value;
  List<String> get values => _tags.map((t) => t.raw).toList();

  bool hasTag(Tag tag) => values.contains(tag.raw);

  final repo = Get.find<Repo>();
  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    debounce(
      query, (q) => onChange(q),
      time: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void onChange(String q) {
    if (q.length < 3) {
      suggests.clear();
      _suggestVisible.value = false;
      return;
    }
    fetch(q);
  }

  int _requestId = 0;

  Future<void> fetch(String q) async {
    isLoading.value = true;
    {
      final int id = ++_requestId;
      String response;
      try {
        response = await repo.api.getSearchTags(q);
      } catch (e) {
        return;
      }
      if (id != _requestId) return;
      _suggestVisible.value = true;
      final List<Tag> parsed = Mapper.parseSearchResults(response);
      suggests.assignAll(parsed);
    }
    isLoading.value = false;
  }

  void add(String tag) {
    final t = Tag(tag);
    if (hasTag(t)) return;
    if (t.raw.isEmpty) return;
    _tags.add(t);
  }

  void remove(Tag tag) => _tags.remove(tag);

  void clearTags() => _tags.clear();

  Future<void> searchForFiles() async {
    final Images images = Get.find();
    List<int> ids = [];
    try {
      ids = await repo.api.getSearchFiles(_tags.map((t) => t.raw).toList());
      await repo.updateServiceNames();
    } catch (e) {
      handleException(e);
      return;
    }
    var list = ids.map((id) => HydrusImage(id)).toList();
    images.assignAll(list);
  }

  void handleException(Object e) {
    switch (e.runtimeType) {
      case const (HydrusNoServiceException):
        Get.snackbar('Error', 'No connection with Hydrus');
      case const (HydrusTimeoutException):
        Get.snackbar('Error', 'No response (timeout)');
      case _:
        Get.snackbar('Error', '$e');
    }
  }

  void clear() {
    _suggestVisible.value = false;
    textController.text = '';
    suggests.clear();
  }
}