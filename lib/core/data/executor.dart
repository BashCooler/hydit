import 'package:dio/dio.dart';
import 'package:dartx/dartx.dart';


enum Type { success, failure }


sealed class Result<T> {
  final Type type;
  final T? data;

  const Result(this.data, {required this.type});
}

class Success<T> extends Result<T> {
  const Success(super.data) : super(type: .success);
}

class Failure<T> extends Result<T> {
  final String title;
  final String message;

  Failure(this.title, this.message) : super(null, type: .failure);
}


class Executor {
  static Future<Result<T>> run<T>(Future<T> Function() action) async {
    try {
      final data = await action();
      return Success(data);
    } on DioException catch (e) {
      final String title;
      final String message;

      switch (e.type) {
        case .badResponse:
          final String exception = e.response?.data['exception_type'] ?? 'Bad response';
          message = e.response?.data['error']
              .replaceAll('!', '') ?? 'No description provided';
          title = exception
              .replaceAllMapped(RegExp(r'(?<!^)(?=[A-Z])'), (match) => ' ')
              .replaceAll(RegExp(r'\s*Exception$'), '')
              .trim()
              .toLowerCase()
              .capitalize();
        case .unknown when e.error.runtimeType == ArgumentError:
          title = 'Client error';
          message = 'No host provided';
        case _:
          title = e.error.runtimeType
              .toString()
              .replaceAllMapped(RegExp(r'(?<!^)(?=[A-Z])'), (match) => ' ')
              .trim()
              .toLowerCase()
              .capitalize();
          message = 'Unknown error occurred with the type "${e.error.runtimeType}"';
          rethrow;  // TODO remove this
      }

      return Failure(title, message);
    }
  }
}