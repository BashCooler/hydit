import 'dart:async';

import 'package:get/get.dart';

import 'package:hydit/api/enums.dart';
import 'package:hydit/api/params.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/services.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';


class QueryController({required final String tag}) {

  final options = SearchOptions.load();

  this {
    search();
  }

  Repo get repo => Get.find();

  Loader get loader => Get.find(tag: tag);

  GalleryController get gallery => Get.find(tag: tag);

  static final pattern = RegExp(r'[{}]');

  @override
  String toString() => options.query.toString().replaceAll(pattern, '');

  bool get isEmpty => options.query.isEmpty;

  void add(String raw) => options.query.addIf(raw.isNotEmpty, Tag(raw));

  void remove(Tag tag) => options.query.remove(tag);

  void clear() => options.query.clear();

  Future<void> search() {
    options.save();

    return repo.api
        .getSearchFiles(options.params)
        .run()
        .loading(gallery.loading)
        .tapSuccess(loader.init)
        .tapFailure(Snack.error);
  }

  void setSortType(FileSortType s) {
    options.sort = s;
    search();
    options.save();
  }

  void setSortAsc(bool asc) {
    options.asc = asc;
    search();
    options.save();
  }
}


class SearchOptions({
  var FileSortType sort = .importTime,
  var bool asc = false,
  required Set<Tag> query,
}) {
  final RxSet<Tag> query = query.obs;

  factory load() => SearchStorage.load();

  void save() => SearchStorage.save(this);

  SearchFilesParams get params => SearchFilesParams(
    tags: query.rawList(),
    fileSortType: sort,
    fileSortAsc: asc,
  );
}


class const SearchStorage._() {
  static const sortKey = 'sort type';

  static const ascKey = 'sort ascending';

  static const queryKey = 'query';

  static Storage get box => Get.find<Storage>();

  static SearchOptions load() => SearchOptions(
    sort: box.get<String>(sortKey).let(FileSortType.byName),
    asc: box.get<bool>(ascKey).or(false),
    query: {
      ...?box.get<List<String>>(queryKey)?.map(Tag.new),
    },
  );

  static void save(SearchOptions options) => box
    ..put(sortKey, options.sort.name)
    ..put(ascKey, options.asc)
    ..put(queryKey, options.query.rawList());
}
