import 'package:flutter/cupertino.dart';
import 'package:full_swipe_back_gesture/full_swipe_back_gesture.dart';
import 'package:get/get.dart';
import 'package:hydit/features/search/page/search.dart';
import 'package:hydit/utils/theme.dart';


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
      duration: AppTheme.duration,
      curve: Curves.easeInOutCubic,
    );
  }
}