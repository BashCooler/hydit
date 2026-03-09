import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/core/data/hydrus.dart';
import 'package:hydrus_flutter/core/data/parser.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';


void updateClient() {
  final prefs = Get.find<SharedPreferences>();
  final key = prefs.getString('Hydrus API key') ?? '';
  final uri = Uri.parse(prefs.getString('URL') ?? '');
  Get.find<Client>().updateClient(key: key, uri: uri);
}


class QueryController extends GetxController {
  final query = ''.obs;
  final suggests = <Tag>[].obs;
  final _tags = <Tag>[].obs;
  final isLoading = false.obs;
  final suggestVisible = false.obs;
  final badgeVisible = true.obs;

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
      suggestVisible.value = true;
      final List<Tag> parsed = parseSearchResults(response);
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
  void clearTags() => _tags.clear();

  Future<void> searchForFiles() async {
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