import 'package:hydit/entities/tag.dart';


class const Changes({
  required final String key,
  required final Set<Tag> add,
  required final Set<Tag> del,
}) {
  bool get isNotEmpty =>
      add.isNotEmpty || del.isNotEmpty;
}
