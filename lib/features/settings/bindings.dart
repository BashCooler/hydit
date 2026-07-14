import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/widgets/swipeable.dart';
import 'package:hydit/features/settings/page/settings_page.dart';


class SettingsPage {

  Widget build() {
    return const SwipeablePage(
      child: Settings(),
    );
  }

  void push() {
    Get.to(
      () => build(),
      opaque: false,
      curve: Curves.easeInOutCubic,
    );
  }
}
