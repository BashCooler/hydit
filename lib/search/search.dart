import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hydrus_flutter/api/hydrus.dart';
import 'package:hydrus_flutter/viewer/images.dart';
import 'package:hydrus_flutter/search/gridview.dart';
import 'package:hydrus_flutter/search/searchbar.dart';
import 'package:hydrus_flutter/settings/settings.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final client = Get.find<Client>();
  final imgCtrl = Get.put<Images>(Images());

  @override
  void initState() {
    super.initState();
    updateClient();
    Get.put<SearchVisibility>(SearchVisibility());
  }

  void updateClient() {
    final prefs = Get.find<SharedPreferences>();
    final key = prefs.getString('Hydrus API key') ?? '';
    final uri = Uri.parse(prefs.getString('URL') ?? '');
    client.updateClientFromPrefs(key: key, uri: uri);
  }

  void searchForFiles(List<String> tags) async {

    List<int> ids = [];
    try {
      ids = await client.getSearchFiles(tags);
    } on HydrusNoServiceException {
      Get.snackbar('Error', 'No connection with Hydrus');
    } on HydrusTimeoutException {
      Get.snackbar('Error', 'No response (timeout)');
    }

    var list = ids.map((id) => HydrusImage(id)).toList();
    imgCtrl.images.assignAll(list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Hydrus client GetX'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => SettingsPage(callback: updateClient)),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Stack(
        alignment: .bottomCenter,
        children: [
          const ImageGridViewBuilder(),
          AnimatedPadding(
            padding: EdgeInsetsGeometry.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: AnimatedLiquidSearchBar(
              onSearch: (s) => searchForFiles([s]),
            ),
          )
        ],
      ),
    );
  }
}


// MARK: SERVICES

class SearchVisibility extends GetxController {
  var visible = true.obs;
  void show() => visible.value = true;
  void hide() => visible.value = false;
}

class Images extends GetxController {
  final images = <HydrusImage>[].obs;
}