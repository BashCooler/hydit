import 'package:hydit/api/enums.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/utils/unicode.dart';
import 'package:hydit/features/editor/entities/changes.dart';


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


class const AddTagsParams(
  final List<int> ids, //
  final List<Changes> changes,
) {
  Map<String, dynamic> toMap() => {
    'file_ids': ids,
    'service_keys_to_actions_to_tags': {
      for (final change in changes)
        if (change.isNotEmpty) change.key: {
          "0": change.added.rawList(),
          "1": change.deleted.rawList(),
        },
    },
  };
}
