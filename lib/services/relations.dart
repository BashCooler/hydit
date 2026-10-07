import 'package:get/get.dart';

import 'package:hydit/api/models.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/services.dart';


class TagRelationService {
  /// Tag -> service key -> relations.
  final _cache = <String, Map<String, TagRelations>>{};

  Repo get repo => Get.find();

  bool isNew(String t) => _cache.containsKey(t).not();

  Future<Result<void>> push(Iterable<String> tags) => tags
      .toSet()
      .where(isNew)
      .let(repo.api.getSiblingsAndParents)
      .run()
      .map(SiblingsAndParentsDto.fromJson)
      .map((dto) => _cache.addAll(dto.tags));

  TagRelations? get({required String raw, required String key}) =>
      _cache[raw]?[key];

  void clear() => _cache.clear();
}
