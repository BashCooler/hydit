import 'package:hydit/api/unicode.dart';
import 'package:hydit/entities/service.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/utils/dictionaries.dart';


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
  final List<int> fileIds;
  final List<TagDiff> changes;

  AddTagsParams({
    required Iterable<int> ids,
    required this.changes,
  })
      : fileIds = ids.toList();

  Map<String, dynamic> toMap() {
    return {
      'file_ids': fileIds,
      'service_keys_to_actions_to_tags': {
        for (final change in changes)
          if (change.isNotEmpty)
            change.key: change.value
      },
    };
  }
}
