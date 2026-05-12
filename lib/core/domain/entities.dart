/// This file contains models widely used across the app
///
/// For the sake of testing `entities.dart` contains only
/// the internal Dart business logic, free from any Flutter
/// dependencies or side effects
///
/// All interface-related functionality has been decoupled and
/// moved to a dedicated `entities_ext.dart` file
///
/// This way we can test API requests or parser functions by
/// running `api.dart`, `mapper.dart`, etc. as console
/// applications
library;

import 'package:get/get.dart';
import 'package:equatable/equatable.dart';

import '../data/repo.dart';


class HydrusFile {
  final ready = false.obs;

  final int id;
  double width = -1;
  double height = -1;
  int size = 0;
  String? type;
  String? ext;
  int duration = 0;
  final service = <String, List<Tag>>{}.obs;

  HydrusFile(this.id);

  int get length => service['all known tags']?.length ?? 0;
  List<Tag> get all => service['all known tags'] ?? [];
  String get res => '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}';

  bool get loading => !ready.value;

  set mime(String value) {
    final m = value.split('/');
    type = m.first;
    ext = m.last;
  }

  Future<void> checkForMetadata() async {
    if (ready.value) return;
    final Repo repo = Get.find();
    await repo.setMetadataFor(this);
  }
}


enum Diff {add, delete}


/// Contains information about a hydrus tag
/// - [raw] - "namespace:tag"
/// - [count] - (optional) useful for presenting the
/// number of entries in search
///
/// Getters:
/// - [namespace]
/// - [value]
///
/// ignore: must_be_immutable
class Tag extends Equatable {
  static Set<String> namespaces = {
    'system',
    'creator',
    'character',
    'meta',
    'series',
    'studio',
  };

  final String raw;
  final int? count;
  Diff? diff;

  Tag(this.raw, {this.count, this.diff});

  String get namespace {
    final idx = raw.indexOf(':');
    return idx == -1 ? 'no namespace' : raw.substring(0 , idx);
  }

  String get value {
    final idx = raw.indexOf(':');
    return idx == -1 ? raw : raw.substring(idx + 1);
  }

  String get pretty {
    final idx = raw.indexOf(':');
    if (idx == -1) return raw;
    final namespace = raw.substring(0 , idx);
    if (namespaces.contains(namespace)) return value;
    return raw;
  }

  @override
  String toString() => raw;

  @override
  List<Object?> get props => [raw];
}
