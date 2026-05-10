import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niku/namespace.dart' as n;
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/domain/file_repo.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/editor/getx/bindings.dart';
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
      ..put(FileRepo())
      ..put(QueryController())
      ..put(SelectionController())
      ..put(GridObserverController(controller: scroll))
      ..put(GalleryController(scroll: scroll));
  }

  @override
  Widget build(BuildContext context) {
    final SelectionController selection = Get.find();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (selection.on) {
          selection.clear();
          return;
        }

        final alert = AlertDialog(
          actionsAlignment: .center,
          icon: const Icon(Icons.close),
          title: 'Close application?'.n,
          actions: [
            n.Button('No'.n)
              ..onPressed = () => Get.back(),
            n.Button('Yes'.n)
              ..onPressed = () => SystemNavigator.pop(),
          ],
        );

        n.showDialog(
          context: context,
          builder: (context) => alert,
        );
      },
      child: Obx(() {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: Get.mediaQuery.viewInsets.top,
            backgroundColor: Get.theme.scaffoldBackgroundColor.withAlpha(90),
          ),
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: const Stack(
            alignment: .bottomRight,
            children: [
              ImageGridViewBuilder(),
              FloatingActions(),
            ],
          ),
          bottomNavigationBar: selection.on
              ? const SelectActions()
              : null,
        );
      }),
    );
  }
}


class FloatingActions extends StatelessWidget {
  const FloatingActions({super.key});

  @override
  Widget build(BuildContext context) {
    final GalleryController gallery = Get.find();
    return Obx(() {
      return AnimatedContainer(
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 350),
        height: gallery.actionsVisible
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


class SelectActions extends StatelessWidget {
  const SelectActions({super.key});

  @override
  Widget build(BuildContext context) {
    final SelectionController selection = Get.find();
    return BottomAppBar(
      color: Get.theme.scaffoldBackgroundColor.withAlpha(90),
      child: n.Row([
        Obx(() {
          return '${selection.ids.length} selected'.n
            ..expanded
            ..color = Colors.white
            ..fontSize = 16
            ..fontWeight = .w500
            ..shadows = [Shadow(blurRadius: 24)]
            ..textAlign = .center;
        }),
        n.Row([
          IconButton(
            tooltip: 'Edit tags',
            icon: const Icon(Icons.edit),
            color: Colors.white,
            onPressed: () {
              final tag = 'Editor-${DateTime.now().microsecondsSinceEpoch}';
              toEditor(tag, .batch);
            },
          ),
          Obx(() {
            switch (selection.rangeSelected) {
              case true:
                return IconButton(
                  tooltip: 'Select range',
                  icon: const Icon(Icons.select_all),
                  color: Colors.white,
                  onPressed: selection.selectRange,
                );
              case false:
                return const SizedBox.shrink();
            }
          }),
        ])
          ..gap = 10
          ..padding = .only(right: 10),
      ])
        ..mainAxisAlignment = .spaceBetween,
    );
  }
}
