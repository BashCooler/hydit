import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/logic/entities_ext.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';


class Suggests extends StatelessWidget {
  final Widget? trailing;
  final bool expanded;
  final void Function(Tag tag) onTap;

  const Suggests({
    super.key,
    this.expanded = true,
    this.trailing,
    required this.onTap,
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
  final void Function(Tag tag) onTap;

  const _TagList(this.trailing, this.onTap);

  @override
  Widget build(BuildContext context) {
    final QueryController controller = Get.find();
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: Scrollbar(
        child: Obx(() => ListView.builder(
          reverse: true,
          itemCount: controller.suggests.length,
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
  final void Function(Tag tag) onTap;

  const _SearchEntry(this.index, this.trailing, this.onTap);

  @override
  Widget build(BuildContext context) {
    final tag = Get.find<QueryController>().suggests[index];
    return ListTile(
      minTileHeight: AppTheme.fieldHeight,
      title: tag.label,
      trailing: trailing ?? Text(
        tag.count.toString(),
        style: TextStyle(color: tag.color, fontSize: 14.0),
      ),
      onTap: () => onTap.call(tag),
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
              Text('Start typing to search tags'),
            ],
          ),
        ),
      ),
    );
  }
}
