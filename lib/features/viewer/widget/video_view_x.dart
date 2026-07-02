import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/features/viewer/getx/video.dart';
import 'package:hydit/features/viewer/widget/video_view.dart';
import 'package:hydit/reactive/file.dart';


class VideoViewX extends StatelessWidget {
  final String tag;
  final HydrusFile file;

  const VideoViewX({
    super.key,
    required this.tag,
    required this.file,
  });

  PageGetxController get page => Get.find(tag: tag);
  VideoGetxController get video => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VideoPlayer(
          controller: video.controller,
          tag: tag,
        ),
      ],
    );
  }
}
