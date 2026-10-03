import 'package:hydit/entities/tag.dart';


class const Changes({
  required final String key,
  required final Set<Tag> added,
  required final Set<Tag> deleted,
}) {
  bool get isNotEmpty =>
      added.isNotEmpty || deleted.isNotEmpty;
}
