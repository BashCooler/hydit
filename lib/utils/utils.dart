export 'theme.dart';


extension ToDuration on num {
  Duration get ms => Duration(milliseconds: round());
  Duration get s => (this * 1000).s;
}

Future<void> sleep(Duration duration) => Future.delayed(duration);
