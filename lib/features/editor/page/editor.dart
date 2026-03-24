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
  final scrollDown = ScrollController();

  final Images images = Get.find();
  final TagManager manager = Get.put(TagManager());
  final PageGetxController page = Get.find();

  @override
  void dispose() {
    scrollUp.dispose();
    scrollDown.dispose();
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
      onPopInvokedWithResult: onLeave,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          toolbarHeight: 100,
          title: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              _Info(),
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
                child: SplitView(
                  viewMode: .Vertical,
                  gripSize: 16,
                  indicator: SplitIndicator(viewMode: SplitViewMode.Vertical),
                  children: [
                    ClipRect(
                      child: Scrollbar(
                        controller: scrollUp,
                        child: ListView.builder(
                          itemCount: 21,
                          shrinkWrap: true,
                          reverse: true,
                          controller: scrollUp,
                          itemBuilder: (context, index) => ListTile(title: Text("$index")),
                        ),
                      ),
                    ),
                    Suggests(
                      trailing: Icon(Icons.add),
                      onTap: manager.add,
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              TagSearchBar(
                hintText: 'Add tags',
                onSubmitted: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _Info extends StatelessWidget {
  const _Info();

  @override
  Widget build(BuildContext context) {
    final Images images = Get.find();
    final PageGetxController page = Get.find();
    final image = images.$[page.i];
    final TagManager manager = Get.find();
    return SizedBox(
      width: 250,
      child: Column(
        spacing: 5,
        crossAxisAlignment: .start,
        children: [
          DefaultTextStyle(
            style: TextStyle(fontSize: 16),
            child: Row(
              crossAxisAlignment: .center,
              children: [
                Obx(() => Text("${image.length + manager.additions - manager.deletions} tags")),
                VerticalDivider(width: 8),
                Obx(() {
                  if (manager.additions > 0) {
                    return Row(
                      children: [
                        Text("+${manager.additions}", style: const .new(color: additions)),
                        const VerticalDivider(width: 6),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
                Obx(() => manager.deletions > 0
                    ? Text("-10", style: const .new(color: deletions))
                    : const SizedBox.shrink()),
              ],
            ),
          ),
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
