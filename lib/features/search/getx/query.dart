import 'dart:async';

import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import 'package:hydit/utils/dictionaries.dart';
import 'package:hydit/services/repo.dart';
import 'package:hydit/services/snack.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';


class QueryController extends GetxController {
  final _tags = <Tag>[].obs;

  final FileStore files;
  final Repo repo = Get.find();
  final GalleryController gallery;

  // Sorting options are global and we can't sort
  // preview galleries for now
  FileSortType _sortType = .importTime;
  bool _sortAsc = false;

  QueryController({required this.files, required this.gallery}) {
    loadSortOption();
    loadAscOption();
    load();
  }

  List<Tag> get tags => _tags;
  List<String> get values => _tags.map((t) => t.raw).toList();

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

  void saveQuery() {
    final box = Hive.box('settings');
    box.put('query', _tags.map((t) => t.raw).toList());
  }

  Future<void> search() async {
    final List<int>? ids = await _getIdsUnsafe()
        .run()
        .loading(gallery.loading)
        .onSuccess((_) => repo.updateServiceNames().onFailure(Snack.error))
        .onFailure(Snack.error)
        .unwrap();

    if (ids == null) return;
    files.assignAll(ids.map(fileFromId).toList());
  }

  HydrusFile fileFromId(int id) => HydrusFile(
    id: id,
    thumbnailUrl: repo.buildUrl(id, thumbnail: true),
    url: repo.buildUrl(id),
  );

  Future<List<int>> _getIdsUnsafe() async => await repo.api.getSearchFiles(
    _tags.rawList,
    fileSortType: _sortType.value,
    fileSortAsc: _sortAsc,
  );

  Future<void> load() async {
    final box = Hive.box('settings');
    final List<String>? tags = box.get('query');
    if (tags != null && tags.isNotEmpty) {
      _tags.assignAll(tags.map((t) => Tag(t)));
      await search();
    }
  }

  // MARK: SORT TYPE

  static const typeKey = 'sort type';
  FileSortType get sortType => _sortType;

  set sortType(FileSortType sortType) {
    _sortType = sortType;
    search();
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

  // MARK: ASC/DESC

  static const ascKey = 'sort ascending';
  bool get sortAsc => _sortAsc;

  set sortAsc(bool sortAsc) {
    _sortAsc = sortAsc;
    search();
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
