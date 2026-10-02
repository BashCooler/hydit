import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/services.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/services/executor.dart';


sealed class const AppError() implements Exception {

  factory from(Object e) => switch (e) {
    AppError() => e,
    DioException() => HydrusConnectionError(e),
    PlatformException() => PlatformError(e),
    _ => UnknownError(e),
  };

  String get title;

  String get message;

  Failure<T> toFailure<T>() => Failure(this);
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


final class const UrlError(final UrlErrorCode code) extends AppError {
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


final class const HydrusConnectionError(final DioException e) extends AppError {

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


final class const PlatformError(final PlatformException e) extends AppError {
  @override
  String get message => 'Platform error';

  @override
  String get title => e.toString();
}


final class const UnknownError(final Object e) extends AppError {
  @override
  String get title => 'Unknown error';

  @override
  String get message => e.toString();
}


final class const CustomError(this.title, this.message) extends AppError {
  @override
  final String title;

  @override
  final String message;
}
