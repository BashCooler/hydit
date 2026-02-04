import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydrus_flutter/api/hydrus.dart';
import 'package:hydrus_flutter/api/parser.dart';
import 'package:hydrus_flutter/viewer/images.dart';


class SearchVisibility extends GetxController {
  var visible = true.obs;
  void show() => visible.value = true;
  void hide() => visible.value = false;
}

class Images extends GetxController {
  final images = <HydrusImage>[].obs;
}

class QueryController extends GetxController {
  final query = ''.obs;
  final suggests = <TagSuggest>[].obs;
  final _tags = <Tag>[].obs;
  final isLoading = false.obs;
  final visible = false.obs;

  List<String> get values => _tags.map((t) => t.raw).toList();
  List<Tag> get tags => _tags;
  bool hasTag(Tag tag) => values.contains(tag.raw);

  final client = Get.find<Client>();
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
        response = await client.getSearchTags(q);
      } catch (e) {
        return;
      }
      if (id != _requestId) return;
      visible.value = true;
      final List<TagSuggest> parsed = parseSearchResults(response);
      suggests.assignAll(parsed);
    }
    isLoading.value = false;
  }

  void addTag(Tag tag) {
    if (hasTag(tag)) return;
    if (tag.raw.isEmpty) return;
    _tags.add(tag);
  }

  void removeTag(Tag tag) => _tags.remove(tag);

  void searchForFiles() async {
    final imageController = Get.find<Images>();
    List<int> ids = [];
    try {
      ids = await client.getSearchFiles(_tags.map((t) => t.raw).toList());
    } catch (e) {
      handleException(e);
      return;
    }
    var list = ids.map((id) => HydrusImage(id)).toList();
    imageController.images.assignAll(list);
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
}


class Tag {
  final String raw;
  const Tag(this.raw);

  String get namespace {
    final idx = raw.indexOf(':');
    return idx == -1 ? 'no namespace' : raw.substring(0 , idx);
  }

  String get value {
    final idx = raw.indexOf(':');
    return idx == -1 ? raw : raw.substring(idx + 1);
  }
}