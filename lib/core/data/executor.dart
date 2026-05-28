import 'package:dio/dio.dart';
import 'package:dartx/dartx.dart';


sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;

  Success({required this.data});
}

class Failure<T> extends Result<T> {
  final String title;
  final String message;

  Failure({required this.title, required this.message});
}


class Executor {
  Executor._();

  /// Safely runs an [action], handles [DioException]s, returns
  /// either [Success] or [Failure].
  ///
  /// [Success] contains data of type [T].
  ///
  /// [Failure] contains a title and a description of the error.
  static Future<Result<T>> run<T>(Future<T> Function() action) async {
    try {
      final data = await action();
      return Success(data: data);

    } on DioException catch (e) {
      final String title;
      final String message;

      switch (e.type) {
        case .badResponse:
          message = e.response
              ?.data['error'] ?? 'No description provided'
              .replaceAll('!', '');
          title = e.response
              ?.data['exception_type'] ?? 'Bad response'
              .format();

        case .connectionError:
          title = 'Connection refused';
          message =
              'This indicates the provided url is incorrect or the Hydrus '
              'client is not running';

        case .unknown when e.error.runtimeType == ArgumentError:
          title = 'Client error';
          message = 'No host provided';

        case _:
          title = e.error.runtimeType.toString().format();
          message =
              'Unknown error occurred with the type "${e.error.runtimeType}"';

          rethrow;  // TODO remove this when handled all error types
      }

      return Failure(title: title, message: message);
    }
  }
}


extension ToReadable on String {
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