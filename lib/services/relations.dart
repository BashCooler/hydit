import 'package:get/get.dart';

import 'package:hydit/api/models.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/services.dart';


class TagRelationService {
  /// Tag -> service key -> relations.
  final _cache = <Tag, Map<String, TagRelations>>{};

  Repo get repo => Get.find();

  bool isNew(Tag t) => _cache.containsKey(t).not();

  Future<Result<void>> push(Iterable<Tag> tags) => tags
      .toSet()
      .where(isNew)
      .map((t) => t.raw)
      .let(repo.api.getSiblingsAndParents)
      .run()
      .map(SiblingsAndParentsDto.fromJson)
      .map((dto) => _cache.addAll(dto.tags));

  Tag? ideal({required Tag tag, required String key}) =>
      _cache[tag]?[key]?.ideal;

  List<Tag> ancestors({required Tag tag, required String key}) =>
      _cache[tag]?[key]?.ancestors ?? .empty();

  void clear() => _cache.clear();
}
