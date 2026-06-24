import 'package:hydit/services/mapper.dart';


class TagService {
  final String name;
  final String key;

  final bool editable;

  TagService(this.name, this.key, {this.editable = false});

  TagService.fromMap(Map<String, dynamic> map, {this.editable = false})
      : name = map['name'],
        key = map['service_key'];
}


extension Find on List<TagService> {

  TagService whereName(String name) {
    return firstWhere((s) => s.name == name);
  }

  void assignAll(Iterable<TagService> elements) {
    clear();
    addAll(elements);
  }

  void fromJson(String json) {
    assignAll(Mapper.mapServices(json));
  }
}
