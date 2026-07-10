import 'dart:async';

import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import 'package:hydit/api/params.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/services.dart';
import 'package:hydit/utils/dictionaries.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';


class QueryController extends GetxController {
  final String tag;

  QueryController({required this.tag}) {
    loadSearchOptions();
    load();
  }

  final _tags = <Tag>[].obs;

  FileSortType _sortType = .importTime;
  bool _sortAsc = false;

  final Repo repo = Get.find();

  Loader get loader => Get.find(tag: tag);
  GalleryController get gallery => Get.find(tag: tag);

  List<Tag> get tags => _tags;
  List<String> get values => _tags.rawList();

  Box get box => Hive.box('settings');

  @override
  String toString() => values.toString().replaceAll(RegExp(r'[\[\]]'), '');

  bool hasTag(Tag tag) => values.contains(tag.raw);

  void add(String tag) {
    final t = Tag(tag);
    if (hasTag(t)) return;
    if (t.raw.isEmpty) return;
    _tags.add(t);
  }

  void remove(Tag tag) => _tags.remove(tag);

  void clear() => _tags.clear();

  void saveQuery() => box.put('query', _tags.rawList());

  Future<Result<List<int>>> search() {
    saveQuery();

    final params = SearchFilesParamsBuilder()
      ..tags = _tags
      ..fileSortType = _sortType
      ..fileSortAsc = _sortAsc;

    return repo.api
        .getSearchFiles(params.build())
        .run()
        .loading(gallery.loading)
        .tapSuccess(loader.init)
        .tapFailure(Snack.error);
  }

  void load() {
    final query = box.get('query') as List<String>?;
    if (query == null || query.isEmpty) return;

    _tags.assignAll(query.toTags());
    search();
  }

  // MARK: SEARCH OPTIONS

  static const typeKey = 'sort type';
  FileSortType get sortType => _sortType;

  set sortType(FileSortType sortType) {
    _sortType = sortType;
    search();
    box.put(typeKey, sortType.name);
  }

  static const ascKey = 'sort ascending';
  bool get sortAsc => _sortAsc;

  set sortAsc(bool sortAsc) {
    _sortAsc = sortAsc;
    search();
    box.put(ascKey, sortAsc);
  }

  void loadSearchOptions() {
    final String? sort = box.get(typeKey);
    switch (sort) {
      case null:
        box.put(typeKey, FileSortType.importTime.name);
      case _:
        _sortType = FileSortType
            .values
            .firstWhere((e) => e.name == sort);
    }

    final bool? asc = box.get(ascKey);
    switch (asc) {
      case null:
        box.put(ascKey, false);
      case _:
        _sortAsc = asc;
    }
  }
}
