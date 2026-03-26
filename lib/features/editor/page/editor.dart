import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:filesize/filesize.dart';
import 'package:hydrus_flutter/features/editor/getx/tags.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';
import 'package:split_view/split_view.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/ui/widget/images.dart';
import 'package:hydrus_flutter/core/ui/widget/suggests.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import 'package:hydrus_flutter/core/ui/widget/tag_search.dart';
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
                constraints: BoxConstraints(maxWidth: 250, maxHeight: 100),
                child: _Info(manager),
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
                    child: SplitView(
                      viewMode: .Vertical,
                      gripSize: 16,
                      indicator: SplitIndicator(viewMode: .Vertical),
                      children: [
                        ClipRect(
                          child: Column(
                            children: [
                              Material(
                                elevation: 1,
                                child: TabBar(
                                  isScrollable: true,
                                  tabAlignment: .center,
                                  onTap: $.selectServiceByIndex,
                                  tabs: $.services.isEmpty
                                      ? [const Tab(text: 'No services')]
                                      : [
                                          for (final service in $.services)
                                            Tab(text: $.pretty(service)),
                                        ],
                                ),
                              ),
                              Expanded(
                                child: TagList(
                                  observable: $.activeTags,
                                  trailing: Icon($.activeServiceEditable
                                      ? Icons.playlist_remove
                                      : Icons.lock_outline),
                                  scrollController: scrollUp,
                                  onTap: $.activeServiceEditable
                                      ? $.delete
                                      : (_) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        Suggests(
                          trailing: Icon($.activeServiceEditable ? Icons.add : Icons.lock_outline),
                          onTap: $.activeServiceEditable ? $.add : (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 1),
              // TODO add remove and insert actions
              Obx(() => TagSearchBar(
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


class _Info extends StatelessWidget {
  final TagManager $;

  const _Info(this.$);

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
            style: TextStyle(fontSize: 16),
            child: Row(
              crossAxisAlignment: .center,
              children: [
                Obx(() => Text("${$.tagCount} tags")),
                VerticalDivider(width: 8),
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
