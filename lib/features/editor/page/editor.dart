import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:filesize/filesize.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/core/ui/images.dart';
import 'package:hydrus_flutter/core/ui/suggests.dart';
import 'package:hydrus_flutter/core/ui/tag_search.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';
import 'package:hydrus_flutter/features/editor/getx/tags.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';


const additions = Color(0xFF3fb950);
const deletions = Color(0xFFf85149);


class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final scrollUp = ScrollController();

  final Images images = Get.find();
  final TagManager manager = TagManager();
  final PageGetxController page = Get.find();

  @override
  void initState() {
    super.initState();
    manager.init(images.$[page.i].service);
  }

  @override
  void dispose() {
    scrollUp.dispose();
    super.dispose();
  }

  void onLeave(bool didPop, Object? result) {
    Future.delayed(
      AppTheme.duration,
      Get.find<QueryController>().clear,
    );
  }

  final controller = MultiSplitViewController(areas: [
    Area(
        min: 0.35,
        flex: 1.4,
        max: 2.375,
        builder: (context, area) => Up()),
    Area(flex: 1, builder: (context, area) => Down()),
  ]);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // TODO confirm dialog
      onPopInvokedWithResult: onLeave,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          toolbarHeight: 100,
          title: Row(
            crossAxisAlignment: .center,
            mainAxisAlignment: .spaceBetween,
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 250,
                  maxHeight: 100),
                child: Info(manager),
              ),
              Obx(() {
                return SizedBox(
                  width: 100,
                  height: 100,
                  child: Thumbnail(images.$[page.i]),
                );
              }),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: GetBuilder(
                  init: manager,
                  builder: ($) => DefaultTabController(
                    length: $.services.isEmpty ? 1 : $.services.length,
                    initialIndex: $.activeIndex,
                    child: MultiSplitView(
                      axis: .vertical,
                      resizable: true,
                      controller: controller,
                      dividerBuilder: (_, _, _, drag, hover, _) {
                        return Container(color: Get.theme.dividerColor);
                      },
                    ),
                  ),
                ),
              ),
              Divider(height: 1),
              // TODO add remove and insert actions
              Obx(() => TagSearchBar(
                enabled: manager.activeServiceEditable,
                hintText: manager.activeServiceEditable
                    ? 'Add tags to ${manager.activeService}'
                    : 'Read-only service selected',
                onSubmitted: () {},
              )),
              // TODO confirm button
            ],
          ),
        ),
      ),
    );
  }
}


class Up extends StatelessWidget {
  final scrollUp = ScrollController();

  Up({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.find<TagManager>(),
      builder: ($) => Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: .center,
            onTap: $.selectServiceByIndex,
            tabs: $.services.isEmpty
                ? [ const Tab(text: 'No services') ]
                : [ for (final service in $.services) Tab(text: $.pretty(service)) ],
          ),
          Expanded(
            child: TagList(
              observable: $.activeTags,
              trailing: Icon($.activeServiceEditable
                  ? Icons.playlist_remove
                  : Icons.lock_outline),
              scrollController: scrollUp,
              onTap: $.activeServiceEditable ? $.delete : null,
            ),
          ),
        ],
      ),
    );
  }
}


class Down extends StatelessWidget {
  const Down({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.find<TagManager>(),
      builder: ($) => Suggests(
        trailing: Icon($.activeServiceEditable
            ? Icons.add
            : Icons.lock_outline),
        onTap: $.activeServiceEditable
            ? $.add
            : (_) {},
      )
    );
  }
}


class Info extends StatelessWidget {
  final TagManager $;

  const Info(this.$, {super.key});

  @override
  Widget build(BuildContext context) {
    final Images images = Get.find();
    final PageGetxController page = Get.find();
    final image = images.$[page.i];
    return SizedBox(
      width: 250,
      child: Column(
        spacing: 5,
        mainAxisAlignment: .center,
        crossAxisAlignment: .start,
        children: [
          DefaultTextStyle(
            style: const TextStyle(fontSize: 16),
            child: Row(
              crossAxisAlignment: .center,
              children: [
                Obx(() => Text("${$.tagCount} tags")),
                const VerticalDivider(width: 8),
                Obx(() {
                  if ($.serviceAdditions > 0) {
                    return Row(
                      children: [
                        Text("+${$.serviceAdditions}", style: const .new(color: additions)),
                        const VerticalDivider(width: 6),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
                Obx(() => $.serviceDeletions > 0
                    ? Text("-${$.serviceDeletions}", style: const .new(color: deletions))
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          Obx(() => Text("service: ${$.activeService}",
            style: Theme.of(context).textTheme.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          Text("id: ${image.id} / "
              "${filesize(image.size)} / "
              "${image.res}",
              style: Theme.of(context).textTheme.labelMedium,
              maxLines: 2
          ),
        ],
      ),
    );
  }
}
