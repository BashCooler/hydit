import 'dart:math' hide log;

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/services/services.dart';


class Loader {
  final String tag;

  FileStore get store => Get.find(tag: tag);

  static const int chunkSize = 20;

  Loader({required this.tag});

  static Repo get repo => Get.find();

  /// Batch is already loading and new requests should
  /// be rejected.
  var _loading = false;

  final _failed = false.obs;

  /// Load failed and this [Loader] is locked until successful
  /// [retry].
  bool get failed => _failed.value;

  /// Clear existing files and load new files.
  void init(Iterable<int> ids) {
    store.ids.assignAll(ids);
    if (store.ids.isEmpty) store.cache.clear();
    loadNextBatch(clear: true);
  }

  /// Load next batch of files if needed.
  void next(int index) {
    if (index < store.length - chunkSize) {
      return;
    }
    loadNextBatch();
  }

  /// Load next batch of files.
  ///
  /// If [clear] is true clears [FileStore] without flicker.
  void loadNextBatch({bool clear = false}) async {
    if (_loading) return;
    if (failed) return retry();

    final start = clear ? 0 : store.length;
    final end = min(start + chunkSize, store.ids.length);

    final batch = store.ids.sublist(start, end);

    if (batch.isEmpty) return;

    _loading = true;

    final files = await load(batch)
        .tapFailure(Snack.error)
        .tapFailure(_fail)
        .unwrap();

    if (files == null) return;

    if (clear) {
      store.commit(files, clear: clear);
    } else {
      store.commit(files);
    }

    _loading = false;
  }

  static Future<Result<List<HydrusFile>>> load(List<int> ids, {
    bool clear = false,
  }) {
    return repo.api
        .getFileMetadata(ids)
        .run()
        .pick('metadata')
        .asListOrThrow(HydrusFile.fromPick);
  }

  Future<Result<void>> ensureLoaded(Iterable<int> ids,
      CancellationToken token) async {

    final chunks = ids
        .where((id) => store.cache[id] == null)
        .chunked(chunkSize);

    for (final chunk in chunks) {

      final files = await load(chunk)
          .tapFailure(Snack.error)
          .tapFailure(_fail);

      if (files is Failure) {
        return files;
      }

      store.commit(files.unwrapOrThrow());

      if (token.cancelled) break;
    }

    return unit.toSuccess();
  }

  void _fail(Failure failure) {
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
        .tapFailure(Snack.error);

    _retrying = false;

    if (ping is Failure) return;

    _failed.value = false;

    // Turn off failed state, then update the grid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadNextBatch();
      _loading = false;
    });
  }
}

extension ToMap on Iterable<HydrusFile> {
  /// The ids to files [Map].
  Map<int, HydrusFile> toMap() => Map.fromIterable(
    this,
    key: (file) => file.id,
  );
}
