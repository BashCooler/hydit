import 'package:get/get.dart';

import 'package:hydit/api/enums.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/storage.dart';

import '../reactive/options.dart';


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
