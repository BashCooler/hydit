import 'package:hydit/api/unicode.dart';
import 'package:hydit/utils/dictionaries.dart';

import '../entities/tag.dart';


/// Parameters builder for POST /add_tags/add_tags request.
///
/// Note: [ids], [key], [action], [tags] must be filled before
/// calling a [build] method.
class AddTagsParamsBuilder {
  List<int>? _ids;
  String? _serviceKey;
  AddTagsAction? _action;
  List<String>? _tags;

  set ids(Iterable<int> ids) => _ids = ids.toList();
  set key(String key) => _serviceKey = key;
  set action(AddTagsAction action) => _action = action;
  set tags(Iterable<Tag> tags) => _tags = tags.rawList();

  AddTagsParams build() {
    return AddTagsParams(
      ids: _ids!,
      serviceKey: _serviceKey!,
      action: _action!,
      tags: _tags!,
    );
  }
}


/// Parameters for POST /add_tags/add_tags request
class AddTagsParams {
  final List<int> ids;
  final String serviceKey;
  final AddTagsAction action;
  final List<String> tags;

  AddTagsParams({
    required this.ids,
    required this.serviceKey,
    required this.action,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'file_ids': ids,
      'service_keys_to_actions_to_tags': {
        serviceKey: {
          "${action.value}": tags,
        }
      }
    };
  }
}


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
