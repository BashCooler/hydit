import 'package:hydit/entities/tag.dart';


class const Changes({
  required final String key,
  required final Set<Tag> _added,
  required final Set<Tag> _deleted,
}) {
  bool get isNotEmpty => _added.isNotEmpty || _deleted.isNotEmpty;

  Map<String, List<String>> get value => {
    "0": _added.rawList(),
    "1": _deleted.rawList(),
  };
}
