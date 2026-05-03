import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/features/gallery/getx/selection.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/settings/ui/page/settings.dart';

import 'search_sheet.dart';
import '../widget/gridview.dart';


class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  void initState() {
    super.initState();
    Get
      ..find<Repo>().updateClient()
      ..put(Images())
      ..put(QueryController())
      ..put(ScrollToHideController())
      ..put(SelectionController())
      ..put(GridObserverController(controller: ScrollController()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: Get.mediaQuery.viewInsets.top,
        backgroundColor: Get.theme.scaffoldBackgroundColor.withAlpha(90),
      ),
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: const Stack(
        alignment: .bottomRight,
        children: [
          ImageGridViewBuilder(),
          BottomActions(),
        ],
      ),
    );
  }
}


class BottomActions extends StatelessWidget {
  const BottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollToHide(
      scrollController: Get.find<GridObserverController>().controller!,
      controller: Get.find<ScrollToHideController>(),
      hideDirection: .vertical,
      height: MediaQuery.of(context).viewPadding.bottom * 2,
      duration: const Duration(milliseconds: 150),
      child: Padding(
        padding: .only(left: 15.0, right: 15.0, bottom: 15.0),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            FilledIconButton(
              onPressed: () =>
                  Get.to(() => const SettingsPage(), transition: .downToUp),
              icon: const Icon(Icons.settings),
            ),
            FilledIconButton(
              onPressed: () => showSearchSheet(context),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }
}