import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/widgets/common/switcher.dart';
import 'package:hydit/widgets/systems/acrylic.dart' as a;
import 'package:hydit/features/search/page/search.dart';

import '../bindings.dart';
import '../getx/loader.dart';
import '../getx/gallery.dart';
import '../getx/selection.dart';

typedef FAB = FloatingActionButton;


class const GalleryFAB({
  super.key,
  required final GallerySession session,
}) extends StatelessWidget {
  //
  GalleryBindings get bindings => session.bindings;

  GalleryController get gallery => bindings.gallery;

  SelectionController get selection => bindings.selection;

  Loader get loader => session.loader;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SequencedSwitcher(
        visible: selection.off && gallery.badges,
        showFirst: loader.ok,
        first: a.FAB(
          icon: const Icon(Icons.search),
          onTap: () => to(
            () => Search(query: session.query),
            curve: Curves.easeInOutCubic,
            opaque: false,
          ),
        ),
        second: FAB(
          onPressed: loader.retry,
          child: const Icon(Icons.refresh),
        ),
      );
    });
  }
}
