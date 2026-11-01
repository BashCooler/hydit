import 'package:get/get.dart';

import 'package:hydit/api/models.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';

import 'base.dart';
import '../widget/toggle_dialog.dart';


class BatchTagManager ({
  @override required final List<HydrusFile> files,
}) extends TagManager {

  this {
    init();
    service = 'my tags';
  }

  final _added = <String, RxSet<Tag>>{};

  Set<Tag> get added => _added[service]!;

  /// Service name -> tag -> count.
  final _counts = <String, Map<Tag, int>>{};

  @override
  Map<String, TagService> get original => files.first.tags;

  @override
  Map<String, Set<Tag>> get initTags {
    final Map<String, Set<Tag>> tags = {};

    final services = files.expand((f) => f.tags.values);

    for (final TagService(:name, :storage) in services) {
      tags.putIfAbsent(name, () => {}).addAll(storage);
      countService(name, storage);
    }

    return tags
      ..forEach((k, _) => _added[k] = <Tag>{}.obs);
  }

  @override
  void toggle(Tag tag) {
    if (!editable || tag.raw.isEmpty) return;

    if (count(tag) == files.length) {
      return super.toggle(tag);
    }

    switch (state(tag)) {
      case .removed:
        current.add(tag);
      case .unchanged:
        showToggleDialog(
          tag,
          onAdd: added.add,
          onDel: current.remove,
          onAny: Get.back,
        );
      case .added when initial.contains(tag):
        added.remove(tag);
      case .added:
        current.remove(tag);
    }
  }

  @override
  TagState state(Tag tag) {
    final state = super.state(tag);

    return state == .unchanged && added.contains(tag)
        ? .added
        : state;
  }

  @override
  int count(Tag tag) => _counts[service]?[tag] ?? 0;

  void countService(String name, Set<Tag> storage) {
    final counts = _counts.putIfAbsent(name, () => {});

    for (final tag in storage) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
  }

  @override
  Set<Tag> additions(String service) =>
      {
        ...super.additions(service),
        ..._added[service]!,
      };
}
