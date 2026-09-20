import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/services.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/executor.dart';


sealed class AppError implements Exception {
  const AppError();

  String get title;

  String get message;

  Failure<T> toFailure<T>() => Failure(title, message);
}


enum UrlErrorCode {
  protocolEmpty,
  urlInvalid,
  portInvalid,
  hostEmpty,
  pathNotEmpty;

  UrlError toError() => UrlError(this);

  Failure<T> toFailure<T>() => toError().toFailure();
}


final class UrlError extends AppError {
  final UrlErrorCode code;

  const UrlError(this.code);

  @override
  String get title => switch (code) {
    .pathNotEmpty => 'Unsupported',
    _ => 'Input error',
  };

  @override
  String get message => switch (code) {
    .protocolEmpty => 'URL must start with "http://" or "https://"',
    .urlInvalid => 'Invalid URL',
    .portInvalid => 'Invalid port',
    .hostEmpty => 'Host is empty',
    .pathNotEmpty => 'URL path must be empty',
  };
}


final class HydrusConnectionError extends AppError {
  final DioException e;

  const HydrusConnectionError(this.e);

  String? get response => e.response?.data;

  @override
  String get title => switch (e.type) {
    .badResponse => response.tryOr(
      (v) => v.pick('exception_type').asStringOrThrow().format(),
      or: 'Bad response',
    ),
    .connectionError => 'Connection refused',
    .connectionTimeout => 'Connection timeout',
    _ => 'Unknown error',
  };

  @override
  String get message => switch (e.type) {
    .badResponse => response.tryOr(
      (v) => v.pick('error').asStringOrThrow().replaceAll('!', ''),
      or: 'The received response does not look like a valid Hydrus response',
    ),
    .connectionError => switch (e.error) {
      SocketException(osError: OSError(errorCode: 101)) => 'No internet connection',
      _ => 'No running Hydrus client found',
    },
    .connectionTimeout => 'No response from Hydrus',
    _ => e.toString(),
  };
}


extension Format on String {
  // ignore: unnecessary_this
  String format() => this
      .replaceAll('Exception', '')
      .addSpaces()
      .toLowerCase()
      .trim()
      .capitalize();

  String addSpaces() =>
      replaceAllMapped(RegExp(r'(?<!^)(?=[A-Z])'), (match) => ' ');
}


final class PlatformError extends AppError {
  final PlatformException e;

  const PlatformError(this.e);

  @override
  String get message => 'Platform error';

  @override
  String get title => e.toString();
}
