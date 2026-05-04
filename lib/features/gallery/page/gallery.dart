import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/settings/ui/page/settings.dart';

import 'search_sheet.dart';
import '../getx/gallery.dart';
import '../getx/selection.dart';
import '../widget/gridview.dart';


class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late final GridObserverController grid;

  @override
  void initState() {
    super.initState();
    final scroll = ScrollController();
    Get
      ..find<Repo>().updateClient()
      ..put(Images())
      ..put(QueryController())
      ..put(SelectionController())
      ..put(GridObserverController(controller: scroll))
      ..put(GalleryController(scroll: scroll));
  }

  @override
  Widget build(BuildContext context) {
    final SelectionController selection = Get.find();
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: selection.selectionMode
              ? '${selection.selectedIds.length} selected'.n
              : null,
          toolbarHeight: selection.selectionMode
              ? null
              : Get.mediaQuery.viewInsets.top,
          backgroundColor: Get
              .theme
              .scaffoldBackgroundColor
              .withAlpha(90),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: selection.clear,
            ),
          ],
          automaticallyImplyLeading: false,
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
    });
  }
}


class BottomActions extends StatelessWidget {
  const BottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    final GalleryController gallery = Get.find();
    return Obx(() {
      return AnimatedContainer(
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 350),
        height: gallery.actionsVisible.value
            ? MediaQuery.of(context).viewPadding.bottom * 2
            : 0,
        child: n.Wrap([
          n.Row([
            FilledIconButton(
              onPressed: () {
                Get.to(() => const SettingsPage(), transition: .downToUp);
              },
              icon: const Icon(Icons.settings),
            ),
            FilledIconButton(
              onPressed: () => showSearchSheet(context),
              icon: const Icon(Icons.search),
            ),
          ])
            ..mainAxisAlignment = .spaceBetween
            ..n.padding = .only(left: 15.0, right: 15.0, bottom: 15.0),
        ]),
      );
    });
  }
}