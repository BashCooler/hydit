import 'dart:math' hide log;
import 'dart:convert' hide json;
import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/services/repo.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/services/snack.dart';


class Loader {
  final ids = <int>[].obs;
  final FileStore store;

  final int chunkSize;

  Loader({
    required this.store,
    this.chunkSize = 20,
  });

  final Repo repo = Get.find();

  /// Batch is already loading and new requests should
  /// be rejected.
  var _loading = false;

  final _failed = false.obs;

  /// Load failed and this [Loader] is locked until successful
  /// [retry].
  bool get failed => _failed.value;

  void next(int index) {
    if (_loading) return;
    if (_failed.value == true) return;
    if (index < store.rx.length - chunkSize) return;

    load();
  }

  void load({bool clear = false}) async {
    var first = true;

    final start = clear ? 0 : store.rx.length;
    final end = min(start + chunkSize, ids.length);

    final load = ids.sublist(start, end);

    if (load.isEmpty) return;

    _loading = true;

    final watch = Stopwatch()..start();

    final json = await repo.api
        .getFileMetadata(load)
        .run()
        .tapFailure(onFailure)
        .unwrap();

    if (json == null) return;

    final files = pick(jsonDecode(json), 'metadata')
        .asListOrThrow((e) => e.asMapOrThrow<String, dynamic>())
        .map(HydrusFile.fromMap);

    if (clear && first) {
      store.rx.assignAll(files);
      first = false;
    } else {
      store.rx.addAll(files);
    }

    log('Length: ${store.rx.length}, time: ${watch.elapsedMilliseconds} ms');

    _loading = false;
  }

  void onFailure(String title, String message) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _failed.value = true);
  }

  bool _retrying = false;

  void retry() async {
    if (_retrying) return;

    _retrying = true;

    final ping = await repo.api
        .getApiVersion()
        .run()
        .tapFailure(Snack.error)
        .unwrap();

    _retrying = false;

    if (ping == null) return;

    _failed.value = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
      _loading = false;
    });
  }
}