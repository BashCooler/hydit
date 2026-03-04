import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/data/hydrus.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';
import 'package:hydrus_flutter/core/ui/widget/widgets.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import 'package:hydrus_flutter/features/settings/settings.dart';

import '../getx/controllers.dart';
import '../widget/search.dart';
import '../widget/gridview.dart';


class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> with SingleTickerProviderStateMixin {
  final client = Get.find<Client>();
  final imgCtrl = Get.put<Images>(Images());

  final scrollController = ScrollController();
  late final GridObserverController gridObserverController;

  @override
  void initState() {
    super.initState();
    updateClient();
    Get.put<SearchVisibility>(SearchVisibility());
    Get.put<QueryController>(QueryController());
    gridObserverController = GridObserverController(controller: scrollController);
    Get.put<GridObserverController>(gridObserverController);
  }

  @override
  void dispose() {
    gridObserverController.controller?.dispose();
    super.dispose();
  }

  void updateClient() {
    final prefs = Get.find<SharedPreferences>();
    final key = prefs.getString('Hydrus API key') ?? '';
    final uri = Uri.parse(prefs.getString('URL') ?? '');
    client.updateClient(key: key, uri: uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: .bottomRight,
        children: [
          const ImageGridViewBuilder(),
          ScrollToHide(
            scrollController: gridObserverController.controller!,
            hideDirection: .vertical,
            height: AppTheme.buttonSize * 2,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const .symmetric(horizontal: AppTheme.outerPadding),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  FilledIconButton(
                    onPressed: () => Get.to(() =>
                        SettingsPage(callback: updateClient)),
                    icon: const Icon(Icons.settings),
                  ),
                  FilledIconButton(
                    onPressed: () => _showModalSheet(context),
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// MARK: SHOW SHEET

void _showModalSheet(BuildContext context) {
  Navigator.push(
    context,
    ModalSheetRoute(
      swipeDismissible: true,
      builder: (context) => SearchSheet(),
      viewportBuilder: (context, child) {
        return SheetViewport(
          padding: .only(top: MediaQuery.viewPaddingOf(context).top),
          child: child,
        );
      },
    ),
  );
}


class SearchSheet extends StatefulWidget {
  const SearchSheet({super.key});

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  @override
  Widget build(BuildContext context) {
    return const PopScope(
      child: SheetKeyboardDismissible(
        dismissBehavior: .onDragDown(isContentScrollAware: true),
        child: Sheet(
          child: FrostedGlass(
            shape: .rRect,
            child: Padding(
              padding: .all(AppTheme.outerPadding),
              child: SafeArea(
                child: Column(
                  spacing: 10.0,
                  mainAxisAlignment: .end,
                  children: [
                    Suggests(),
                    TagPanel(trailing: _TagPanelActions()),
                    TagSearchBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _TagPanelActions extends StatelessWidget {
  const _TagPanelActions();

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    return Row(
      spacing: 4.0,
      children: [
        IconButton(
          tooltip: 'Clear tags',
          onPressed: () => queryController.clearTags(),
          icon: const Icon(Icons.clear),
        ),
        IconButton(
          onPressed: () {
            queryController.addTag(Tag(queryController.textController.text));
            queryController.textController.text = '';
            queryController.visible.value = false;
          },
          icon: const Icon(Icons.arrow_drop_up),
          tooltip: 'Insert input as tag',
        ),
      ],
    );
  }
}