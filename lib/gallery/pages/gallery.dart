import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:keyboard_insets/keyboard_insets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hydrus_flutter/api/hydrus.dart';
import 'package:hydrus_flutter/gallery/widgets/gridview.dart';
import 'package:hydrus_flutter/gallery/services.dart';
import 'package:hydrus_flutter/settings/settings.dart';


class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> with SingleTickerProviderStateMixin {
  final client = Get.find<Client>();
  final imgCtrl = Get.put<Images>(Images());

  @override
  void initState() {
    super.initState();
    updateClient();
    // Get.put<SearchVisibility>(SearchVisibility());
    Get.put<QueryController>(QueryController());
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Hydrus client'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => SettingsPage(callback: updateClient)),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Stack(
        alignment: .bottomRight,
        children: [
          const ImageGridViewBuilder(),
          SafeArea(
            child: IconButton(
              onPressed: () => _showModalSheet(context),
              icon: Icon(Icons.search),
            ),
          )
        ],
      ),
    );
  }
}


void _showModalSheet(BuildContext context) {
  Navigator.push(
    context,
    ModalSheetRoute(
      swipeDismissible: true,
      builder: (context) => SearchPage(),
      viewportBuilder: (context, child) {
        return SheetViewport(
          padding: .only(top: MediaQuery.viewPaddingOf(context).top),
          child: child,
        );
      },
    ),
  );
}


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    PersistentSafeAreaBottom.startObserving();
    PersistentSafeAreaBottom.notifier?.addListener(printSafeAreaBottom);
    KeyboardInsets.stateStream.listen((event) {
      log('Keyboard height: ${event.isAnimating} v=${event.isVisible} ${KeyboardInsets.keyboardHeight}');
      setState(() {});
    });
  }

  void printSafeAreaBottom() {
    log('Safe area height: ${PersistentSafeAreaBottom.notifier?.value}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: SheetKeyboardDismissible(
        dismissBehavior: const .onDragDown(isContentScrollAware: true),
        child: Sheet(
          shrinkChildToAvoidDynamicOverlap: false,
          scrollConfiguration: const SheetScrollConfiguration(),
          child: StreamBuilder(
            stream: KeyboardInsets.insets,
            builder: (context, snapshot) {
              return PersistentSafeArea(
                child: Column(
                  mainAxisAlignment: .end,
                  children: [
                    Padding(
                      padding: .all(15.0),
                      child: Material(child: TextField(autofocus: true)),
                    ),
                    SizedBox(height: snapshot.data),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}