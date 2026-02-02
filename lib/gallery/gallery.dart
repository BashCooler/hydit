import 'dart:developer';

import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/search/search.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hydrus_flutter/api/hydrus.dart';
import 'package:hydrus_flutter/api/parser.dart';
import 'package:hydrus_flutter/viewer/images.dart';
import 'package:hydrus_flutter/gallery/gridview.dart';
import 'package:hydrus_flutter/settings/settings.dart';

import '../settings/theme.dart';


class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> with SingleTickerProviderStateMixin {
  final client = Get.find<Client>();
  final imgCtrl = Get.put<Images>(Images());
  late final AnimationController _animationController;
  late final Animation<Offset> _slide;
  late final Worker _visibilityWorker;

  @override
  void initState() {
    super.initState();
    updateClient();
    Get.put<SearchVisibility>(SearchVisibility());
    Get.put<QueryController>(QueryController());
    Get.put<QueryController>(QueryController());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0.8),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    final visibility = Get.find<SearchVisibility>();
    _visibilityWorker = ever<bool>(visibility.visible, (v) {
      if (v) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _visibilityWorker.dispose();
  }

  void updateClient() {
    final prefs = Get.find<SharedPreferences>();
    final key = prefs.getString('Hydrus API key') ?? '';
    final uri = Uri.parse(prefs.getString('URL') ?? '');
    client.updateClientFromPrefs(key: key, uri: uri);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Scaffold(
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
        body: SafeArea(
          child: Stack(
            alignment: .bottomCenter,
            children: [
              const ImageGridViewBuilder(),
              SlideTransition(
                position: _slide,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(Consts.searchPadding),
                  child: RepaintBoundary(
                    child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadiusGeometry.circular(Consts.radius),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: Consts.blur, sigmaY: Consts.blur),
                        child: Card.outlined(
                          color: Consts.blackAlpha,
                          margin: EdgeInsets.zero,
                          child: TagPanel(clickable: true),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class TagPanel extends StatelessWidget {
  final bool clickable;

  const TagPanel({
    super.key,
    required this.clickable,
  });

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    return Card.outlined(
      color: Consts.blackAlpha,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: Obx(() {
        final tags = queryController._tags;
        return Stack(
          children: [
            ListTile(
              title: tags.isNotEmpty ? null :Text('Search for tags'),
              onTap: !clickable ? null : () => Get.dialog(
                SearchPage(),
                barrierColor: Consts.blackAlpha,
                transitionDuration: Duration(milliseconds: 200),
                transitionCurve: Curves.easeInOutBack,
                useSafeArea: false,
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsetsGeometry.all(6.0),
              scrollDirection: .horizontal,
              child: Wrap(
                spacing: 5.0,
                children: [
                  for (final tag in tags) InputChip(
                    label: Text(tag.value),
                    backgroundColor: namespaceColors[tag.namespace]
                        ?? namespaceColors['namespace'],
                    onDeleted: () => queryController.removeTag(tag),
                  ),
                ],
              ),
            )
          ],
        );
      }),
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

class QueryController extends GetxController {
  final query = ''.obs;
  final suggests = <TagSuggest>[].obs;
  final _tags = <Tag>[].obs;
  final isLoading = false.obs;
  final visible = false.obs;

  List<String> get values => _tags.map((t) => t.raw).toList();
  bool hasTag(Tag tag) => values.contains(tag.raw);

  final client = Get.find<Client>();
  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    debounce(
      query, (q) => onChange(q),
      time: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void onChange(String q) {
    if (q.length < 3) {
      suggests.clear();
      return;
    }
    fetch(q);
  }

  int _requestId = 0;

  Future<void> fetch(String q) async {
    isLoading.value = true;
    {
      final int id = ++_requestId;
      final response = await client.getSearchTags(q);
      if (id != _requestId) return;
      visible.value = true;
      final List<TagSuggest> parsed = parseSearchResults(response);
      suggests.assignAll(parsed);
    }
    isLoading.value = false;
  }

  void addTag(Tag tag) {
    if (hasTag(tag)) return;
    if (tag.raw.isEmpty) return;
    _tags.add(tag);
  }

  void removeTag(Tag tag) => _tags.remove(tag);

  void searchForFiles() async {
    final imageController = Get.find<Images>();
    List<int> ids = [];
    try {
      ids = await client.getSearchFiles(_tags.map((t) => t.raw).toList());
    } on HydrusNoServiceException {
      Get.snackbar('Error', 'No connection with Hydrus');
    } on HydrusTimeoutException {
      Get.snackbar('Error', 'No response (timeout)');
    }
    var list = ids.map((id) => HydrusImage(id)).toList();
    imageController.images.assignAll(list);
  }
}


class Tag {
  final String raw;
  const Tag(this.raw);

  String get namespace {
    final idx = raw.indexOf(':');
    return idx == -1 ? 'no namespace' : raw.substring(0 , idx);
  }

  String get value {
    final idx = raw.indexOf(':');
    return idx == -1 ? raw : raw.substring(idx + 1);
  }
}