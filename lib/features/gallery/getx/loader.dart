import 'dart:math' show min;

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/api/models.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/services/services.dart';


mixin LoaderState {
  /// Batch is already loading and new requests should
  /// be rejected.
  var _loading = false;

  final _failed = false.obs;

  /// Loader is in failed  state and locked until
  /// successful call of [retry].
  bool get failed => _failed.value;

  bool _retrying = false;
}


class Loader({required final String tag, final int chunkSize = 20})
    with LoaderState {

  FileStore get store => Get.find(tag: tag);

  Api get api => Get.find();

  TagRelationService get relations => Get.find();

  /// Clear existing files and load new files.
  void init(Iterable<int> ids) {
    store.ids.assignAll(ids);

    if (store.ids.isEmpty) {
      store.loaded.clear();
      store.cache.clear();
    }

    relations.clear();

    _loadNextBatch(clear: true);
  }

  /// Load next batch of files if needed.
  void next(int index) {
    if (index < store.length - chunkSize) {
      return;
    }
    if (!failed) _loadNextBatch();
  }

  /// Load next batch of files.
  ///
  /// If [clear] is true clears [FileStore] without flicker.
  void _loadNextBatch({bool clear = false}) async {
    if (_loading) return;

    if (failed) return retry();

    final start = clear ? 0 : store.length;
    final end = min(start + chunkSize, store.ids.length);

    final batch = store.ids.sublist(start, end);

    if (batch.isEmpty) return;

    _loading = true;

    await _load(batch, clear: clear);

    _loading = false;
  }

  Future<Result<void>> _load(List<int> ids, {
    bool clear = false,
  }) {
    return runCatching(
      () => api.getFileMetadata(ids),
    ).tapSuccessCatching(
      (dto) async {
        final tags = dto.expand((m) => m.tags.all.storage);
        await relations.push(tags);
      },
    ).match(
      ok: (dto) {
        final files = dto.map(HydrusFile.fromDto);
        store.commit(files, clear: clear);
      },
      err: (e) {
        Snack.error(e);
        _fail(e);
      },
    );
  }

  Future<Result<void>> ensureLoaded(Iterable<int> ids,
      CancellationToken token) async {

    final chunks = ids
        .where((id) => store.cache[id] == null)
        .chunked(chunkSize);

    for (final chunk in chunks) {

      final files = await _load(chunk)
          .tapFailure(Snack.error)
          .tapFailure(_fail);

      if (files is Failure) {
        return files;
      }

      // TODO store.commit(files.getOrThrow());

      if (token.cancelled) break;
    }

    return unit.toSuccess();
  }

  void _fail(_) {
    // Add for the grid to rebuild then update state
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _failed.value = true);
  }

  /// Turn off failed state, then update the grid.
  void _recover(_) {
    _failed.value = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNextBatch();
      _loading = false;
    });
  }

  void retry() async {
    if (_retrying || !_failed.value) return;

    _retrying = true;

    await api.getVerifyAccessKey().run()
        .tapSuccess(_recover)
        .tapFailure(Snack.error);

    _retrying = false;
  }
}
