import 'dart:async';

import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydit/services/snack.dart';

import 'package:hydit/utils/dictionaries.dart';
import 'package:hydit/services/repo.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/files.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';


class QueryController extends GetxController {
  final _tags = <Tag>[].obs;

  final FileStore fileRepo;
  final Repo repo = Get.find();
  final GalleryController gallery;

  // Sorting options are global and we can't sort
  // preview galleries for now
  FileSortType _sortType = .importTime;
  bool _sortAsc = false;

  QueryController({required this.fileRepo, required this.gallery}) {
    loadSortOption();
    loadAscOption();
    load();
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

  void saveQuery() {
    final box = Hive.box('settings');
    box.put('query', _tags.map((t) => t.raw).toList());
  }

  Future<void> searchForFiles() async {
    if (_tags.isEmpty) return;
    gallery.refreshing.value = true;
    await _searchForFiles();
    gallery.refreshing.value = false;
    saveQuery();
  }

  Future<void> _searchForFiles() async {
    List<int> ids;

    final result = await Executor.run<List<int>>(_getIdsUnsafe);

    switch (result) {
      case Success(data: final data):
        ids = data;
      case Failure(title: final title, message: final message):
        Snack.error(title, message);
        return;
    }

    final update = await repo.updateServiceNames();

    switch (update) {
      case Success(data: final _):
        break;
      case Failure(title: final title, message: final message):
        Snack.error(title, message);
        return;
    }

    final files = ids.map((id) => HydrusFile(id: id)).toList();
    fileRepo.assignAll(files);
  }

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
      await searchForFiles();
    }
  }

  // MARK: SORT TYPE

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

  // MARK: ASC/DESC

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
