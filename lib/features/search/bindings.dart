import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:full_swipe_back_gesture/full_swipe_back_gesture.dart';
import 'package:hydit/features/search/getx/query.dart';

import 'page/search.dart';


class SearchPage {
  final QueryController query;

  SearchPage({required this.query});

  Widget build() {
    return SwipeablePage(
      child: Search(query: query),
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
