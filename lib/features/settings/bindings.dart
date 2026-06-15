import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:full_swipe_back_gesture/full_swipe_back_gesture.dart';

import 'page/settings_page.dart';


class SearchPage {
  final String tag;

  SearchPage(this.tag);

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
    );
  }
}