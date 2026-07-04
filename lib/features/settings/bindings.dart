import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/widgets/swipeable.dart';
import 'package:hydit/features/settings/getx/settings.dart';
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
      transition: .rightToLeft,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      binding: BindingsBuilder
          .put(() => SettingsController()),
    );
  }
}