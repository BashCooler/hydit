import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import 'package:hydit/utils/dictionaries.dart';
import 'package:hydit/core/data/api.dart';
import 'package:hydit/core/data/mapper.dart';
import 'package:hydit/core/data/repo.dart';
import 'package:hydit/core/domain/entities.dart';
import 'package:hydit/core/domain/file_repo.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';


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
  final isLoading = false.obs;

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

  void clear() {
    _suggestVisible.value = false;
    controller.text = '';
    suggests.clear();
  }
}


class QueryController extends GetxController {
  final _tags = <Tag>[].obs;

  final FileRepo? fileRepo;
  final Repo repo = Get.find();
  final GalleryController? gallery;

  // Sorting options are global and we can't sort
  // preview galleries for now
  FileSortType _sortType = .importTime;
  bool _sortAsc = false;

  QueryController({this.fileRepo, required this.gallery}) {
    loadSortOption();
    loadAscOption();
  }

  List<Tag> get tags => _tags;
  List<String> get values => _tags.map((t) => t.raw).toList();

  bool hasTag(Tag tag) => values.contains(tag.raw);

  void add(String tag) {
    final t = Tag(tag);
    if (hasTag(t)) return;
    if (t.raw.isEmpty) return;
    _tags.add(t);
  }

  void remove(Tag tag) => _tags.remove(tag);

  void clearTags() => _tags.clear();

  Future<void> searchForFiles() async {
    gallery!.refreshing.value = true;

    List<int> ids = [];

    try {
      ids = await repo.api.getSearchFiles(
        _tags.map((t) => t.raw).toList(),
        fileSortType: _sortType.value,
        fileSortAsc: _sortAsc,
      );
      await repo.updateServiceNames();
      var list = ids.map((id) => HydrusFile(id)).toList();
      fileRepo!.assignAll(list);
    } catch (e) {
      handleException(e);
      return;
    } finally {
      gallery!.refreshing.value = false;
    }
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


extension Sort on QueryController {
  static const typeKey = 'sort type';

  FileSortType get sortType => _sortType;

  set sortType(FileSortType sortType) {
    _sortType = sortType;
    searchForFiles();
    Hive.box('settings').put(typeKey, sortType.name);
  }

  void loadSortOption() {
    final box = Hive.box('settings');
    final String? sort = box.get(typeKey);
    switch (sort) {
      case null:
        box.put(typeKey, FileSortType.importTime.name);
      case _:
        _sortType = FileSortType
            .values
            .firstWhere((e) => e.name == sort);
    }
  }
}


extension Asc on QueryController {
  static const ascKey = 'sort ascending';

  bool get sortAsc => _sortAsc;

  set sortAsc(bool sortAsc) {
    _sortAsc = sortAsc;
    searchForFiles();
    Hive.box('settings').put(ascKey, sortAsc);
  }

  void loadAscOption() {
    final box = Hive.box('settings');
    final bool? asc = box.get(ascKey);
    switch (asc) {
      case null:
        box.put(ascKey, false);
      case _:
        _sortAsc = asc;
    }
  }
}
