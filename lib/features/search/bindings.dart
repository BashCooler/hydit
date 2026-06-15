import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:full_swipe_back_gesture/full_swipe_back_gesture.dart';

import 'page/search.dart';


class SearchPage {
  final String tag;

  SearchPage(this.tag);

  Widget build() {
    return SwipeablePage(
      child: Search(tag: tag),
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
