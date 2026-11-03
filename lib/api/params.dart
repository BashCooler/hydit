import 'api.dart';
import 'enums.dart';


class const SearchFilesParams({
  required final List<String> tags,
  required final FileSortType fileSortType,
  required final bool fileSortAsc,
}) {
  Map<String, dynamic> toMap() => {
    'tags': tags.encode(),
    'file_sort_type': fileSortType.value,
    'file_sort_asc': fileSortAsc,
  };
}


class const Changes(final String key, {
  required final List<String> del,
  required final List<String> add,
}) {
  bool get isNotEmpty => add.isNotEmpty || del.isNotEmpty;
}


class AddTagsParams(
  final List<int> ids, //
  Iterable<Changes> changes,
) {
  final List<Changes> changes = changes.toList();

  Map<String, dynamic> toMap() => {
    'file_ids': ids,
    'service_keys_to_actions_to_tags': {
      for (final change in changes)
        if (change.isNotEmpty)
          change.key: {
            "0": change.add,
            "1": change.del,
          },
    },
  };
}
