import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydrus_flutter/core/ui/widget/tag_search.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';
import 'package:split_view/split_view.dart';

import 'package:hydrus_flutter/core/logic/entities.dart';
import 'package:hydrus_flutter/core/ui/widget/images.dart';
import 'package:hydrus_flutter/core/ui/widget/suggests.dart';


class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final scrollControllerUp = ScrollController();
  final scrollControllerDown = ScrollController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) =>
          Get.find<QueryController>().clear(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          toolbarHeight: 100,
          title: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: .center,
                    children: [
                      Text("128 tags", style: Theme.of(context).textTheme.bodyLarge),
                      Text("+12", style: TextStyle(
                        color: Color(0xFF3fb950),
                        fontSize: 16,
                      )),
                      Text("-10", style: TextStyle(
                        color: Color(0xFFf85149),
                        fontSize: 16,
                      )),
                    ],
                  ),
                  Text("id: 123456 / 1.24MB / 960x1400", style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Thumbnail(HydrusImage(182638344)),
              ),
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
                        controller: scrollControllerUp,
                        child: ListView.builder(
                          itemCount: 21,
                          shrinkWrap: true,
                          reverse: true,
                          controller: scrollControllerUp,
                          itemBuilder: (context, index) => ListTile(title: Text("$index")),
                        ),
                      ),
                    ),
                    Suggests(
                      trailing: Icon(Icons.add),
                      onTap: () {
                        // add to the list above
                      },
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
