import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/logic/entities_ext.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';


class Suggests extends StatelessWidget {
  final Widget? trailing;
  final bool expanded;
  final void Function()? onTap;

  const Suggests({
    super.key,
    this.expanded = true,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QueryController>();
    return Obx(() => controller.suggestsVisible
        ? _TagList(trailing, onTap)
        : const _Hint());
  }
}


class _TagList extends StatelessWidget {
  final Widget? trailing;
  final void Function()? onTap;

  const _TagList(this.trailing, this.onTap);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QueryController>();
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: Scrollbar(
        child: Obx(() => ListView.builder(
          reverse: true,
          itemCount: ctrl.suggests.length,
          itemBuilder: (_, index) =>
              _SearchEntry(index, trailing, onTap),
        )),
      ),
    );
  }
}

class _SearchEntry extends StatelessWidget {
  final int index;
  final Widget? trailing;
  final void Function()? onTap;

  const _SearchEntry(this.index, this.trailing, this.onTap);

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    final tag = queryController.suggests[index];
    return ListTile(
      minTileHeight: AppTheme.fieldHeight,
      title: tag.label,
      trailing: trailing ?? Text(
        tag.count.toString(),
        style: TextStyle(color: tag.color, fontSize: 14.0),
      ),
      onTap: () {
        queryController.clear();
        if (onTap != null) {
          onTap!();
        } else {
          queryController.add(tag);
        }
      },
    );
  }
}


class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .bottomCenter,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: .only(bottom: 45),
          child: Column(
            mainAxisAlignment: .center,
            spacing: 15,
            children: [
              Icon(Icons.search, size: 96),
              Text('No results for now'),
            ],
          ),
        ),
      ),
    );
  }
}
