import 'dart:async';

import 'package:get/get.dart';

import 'package:hydit/api/enums.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/services.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';

import '../reactive/options.dart';


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
