import 'package:hydit/reactive/file.dart';
import 'package:hydit/utils/collection.dart';


class FileCache extends DelegatingMapBase<int, HydrusFile> {

  final cache = <int, HydrusFile>{};

  @override
  Map<int, HydrusFile> get delegate => cache;
}
