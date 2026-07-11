import 'dart:math' hide log;
import 'dart:convert' hide json;

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/services/services.dart';


class Loader {
  final String tag;

  FileStore get store => Get.find(tag: tag);

  static const int chunkSize = 20;

  Loader({required this.tag});

  final Repo repo = Get.find();

  /// Batch is already loading and new requests should
  /// be rejected.
  var _loading = false;

  final _failed = false.obs;

  /// Load failed and this [Loader] is locked until successful
  /// [retry].
  bool get failed => _failed.value;

  void init(Iterable<int> ids) {
    if (store.ids.isEmpty) store.cache.clear();
    store.ids.assignAll(ids);
    load(clear: true);
  }

  /// Load next batch of files if needed.
  void next(int index) {
    if (_loading) return;
    if (_failed.value == true) return;
    if (index < store.length - chunkSize) return;

    load();
  }

  /// Forcefully load next batch of files.
  ///
  /// If [clear] is true clears [FileStore] without flicker.
  Future<Result<void>> load({bool clear = false, List<int>? ids}) async {
    if (failed) {
      retry();
      return Success(null);
    }

    final start = clear ? 0 : store.length;
    final end = min(start + chunkSize, store.ids.length);

    final load = ids ?? store.ids.sublist(start, end);

    if (load.isEmpty) return Success(null);

    _loading = true;

    final result = await repo.api
        .getFileMetadata(load)
        .run()
        .tapFailure(Snack.error)
        .tapFailure(_fail);

    final json = result.unwrap();

    if (json == null) return result;

    final files = pick(jsonDecode(json), 'metadata')
        .asListOrThrow((e) => e.asMapOrThrow<String, dynamic>())
        .map(HydrusFile.fromMap);

    final map = Map<int, HydrusFile>.fromIterable(
      files,
      key: (file) => file.id,
    );

    if (clear) {
      store.cache.assignAll(map);
    } else {
      store.cache.addAll(map);
    }

    _loading = false;

    return Success(null);
  }

  Future<Result<void>> ensureLoaded(Iterable<int> ids,
      CancellationToken token) async {

    final toLoad = <int>[];

    for (final id in ids) {
      if (store.cache[id] == null) toLoad.add(id);
    }

    final chunks = toLoad.chunked(chunkSize);

    for (final chunk in chunks) {
      await load(ids: chunk);
      if (token.cancelled) return Success(null);
    }

    return Success(null);
  }

  void _fail(String title, String message) {
    // Add for the grid to rebuild then update state
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _failed.value = true);
  }

  bool _retrying = false;

  void retry() async {
    if (_retrying || !_failed.value) return;

    _retrying = true;

    final ping = await repo.api
        .getApiVersion()
        .run()
        .tapFailure(Snack.error)
        .unwrap();

    _retrying = false;

    if (ping == null) return;

    _failed.value = false;

    // Turn off failed state, then update the grid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
      _loading = false;
    });
  }
}