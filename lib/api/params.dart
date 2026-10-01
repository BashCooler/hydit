import 'package:hydit/api/enums.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/changes.dart';
import 'package:hydit/utils/unicode.dart';


class SearchFilesParamsBuilder {
  Iterable<String>? _tags;
  FileSortType? _fileSortType;
  bool? _fileSortAsc;

  set tags(Iterable<Tag> tags) => _tags = tags.rawList();
  set fileSortType(FileSortType sortType) => _fileSortType = sortType;
  set fileSortAsc(bool ascending) => _fileSortAsc = ascending;

  SearchFilesParams build() {
    return SearchFilesParams(
      tags: _tags!,
      fileSortType: _fileSortType!,
      fileSortAsc: _fileSortAsc!,
    );
  }
}


class SearchFilesParams {
  final Iterable<String> tags;
  final FileSortType fileSortType;
  final bool fileSortAsc;

  SearchFilesParams({
    required this.tags,
    required this.fileSortType,
    required this.fileSortAsc,
  });

  Map<String, dynamic> toMap() {
    return {
      'tags': tags.toList().encode(),
      'file_sort_type': fileSortType.value,
      'file_sort_asc': fileSortAsc,
    };
  }
}


class AddTagsParams {
  final List<int> ids;
  final List<TagChanges> changes;

  AddTagsParams(this.ids, this.changes);

  Map<String, dynamic> toMap() {
    return {
      'file_ids': ids,
      'service_keys_to_actions_to_tags': {
        for (final change in changes)
          if (change.isNotEmpty)
            change.key: change.value
      },
    };
  }
}
