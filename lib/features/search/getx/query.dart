import 'dart:async';

import 'package:get/get.dart';

import 'package:hydit/api/enums.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/services.dart';

import '../reactive/options.dart';


class QueryController({
  final void Function()? beforeSearch,
  final void Function()? afterSearch,
  required final void Function(List<int> ids) onResults,
}) {

  final options = SearchOptions.load();

  this {
    search();
  }

  Repo get repo => Get.find();

  static final pattern = RegExp(r'[{}]');

  @override
  String toString() => options.query.toString().replaceAll(pattern, '');

  /// Whether this query has no tags.
  bool get isEmpty => options.query.isEmpty;

  /// Add tag to this query.
  void add(String raw) => options.query.addIf(raw.isNotEmpty, Tag(raw));

  /// Remove [tag] from the query.
  void remove(Tag tag) => options.query.remove(tag);

  /// Remove all tags from the query.
  void clear() => options.query.clear();

  Future<void> search() {
    options.save();

    beforeSearch?.call();

    return repo.api
        .getSearchFiles(options.params)
        .run()
        .tapSuccess(onResults)
        .tapFailure(Snack.error)
        .tap((_) => afterSearch?.call());
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
