import 'package:get/get.dart';

import 'package:hydit/api/enums.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/services.dart';
import 'package:hydit/features/gallery/bindings.dart';

import '../reactive/options.dart';


class QueryController({
  required final GallerySession session,
}) {

  final options = SearchOptions.load();

  this {
    search();
  }

  Api get api => Get.find();

  GalleryBindings get bindings => session.bindings;

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

  Future<void> search({
    bool jumpUp = false,
    bool animateUp = false,
  }) async {
    options.save();

    if (api.url.isEmpty || session.loading.value) return;

    session.loading.value = true;

    if (jumpUp) bindings.gallery.jumpUp();
    if (animateUp) bindings.gallery.animateUp();

    await api.getSearchFiles(options.params).runMatch(
      ok: session.loader.init,
      err: Snack.error,
    );

    session.loading.value = false;
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
