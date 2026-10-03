import 'package:get/get.dart';

import 'package:hydit/api/enums.dart';
import 'package:hydit/api/params.dart';
import 'package:hydit/entities/tag.dart';

import '../services/storage.dart';


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
