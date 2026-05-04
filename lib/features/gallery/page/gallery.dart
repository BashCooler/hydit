import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:niku/namespace.dart' as n;
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/settings/ui/page/settings.dart';

import 'search_sheet.dart';
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
    Get
      ..find<Repo>().updateClient()
      ..put(Images())
      ..put(QueryController())
      ..put(SelectionController());
    final scroll = ScrollController();
    grid = Get.put(GridObserverController(controller: scroll));
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
        body: Stack(
          alignment: .bottomRight,
          children: [
            const ImageGridViewBuilder(),
            BottomActions(controller: grid.controller!),
          ],
        ),
      );
    });
  }
}


class BottomActions extends StatefulWidget {
  final ScrollController controller;

  const BottomActions({super.key, required this.controller});

  @override
  State<BottomActions> createState() => _BottomActionsState();
}

class _BottomActionsState extends State<BottomActions> {
  var visible = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listener);
  }

  void listener() {
    final direction = widget.controller.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      setState(() => visible = true);
    } else if (direction == ScrollDirection.reverse) {
      setState(() => visible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: Curves.linear,
      duration: const Duration(milliseconds: 150),
      height: visible
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
  }
}