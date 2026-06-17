library;

import 'package:get/get_rx/src/rx_types/rx_types.dart';

export 'theme.dart';


extension Delay on void Function() {
  void Function() delayed(Duration duration) {
    return () => Future.delayed(duration, this);
  }
}


extension ToDuration on num {
  Duration get mcs => Duration(microseconds: round());
  Duration get ms  => (this * 1000).mcs;
  Duration get s   => (this * 1000 * 1000).mcs;
  Duration get m   => (this * 1000 * 1000 * 60).mcs;
  Duration get h   => (this * 1000 * 1000 * 60 * 60).mcs;
  Duration get d   => (this * 1000 * 1000 * 60 * 60 * 24).mcs;
}


extension FluentApi on RxBool {
  Future<RxBool> set(bool value) async {
    this.value = value;
    return this;
  }

  Future<RxBool> then(Future<void> Function() action) async {
    await action();
    return this;
  }
}
