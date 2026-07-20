import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydit/reactive/file.dart';


class TileBadges extends StatelessWidget {
  final HydrusFile file;

  const TileBadges(this.file, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(8.0),
      child: Column(
        mainAxisAlignment: .spaceBetween,
        children: [
          Wrap(
            spacing: 2,
            runSpacing: 2,
            children: [
              Obx(() => InboxBadge(isInbox: file.isInbox)),
            ],
          ),
          Wrap(
            spacing: 2,
            runSpacing: 2,
            children: BadgesBuilder(file)
                .addNumerical('volume', 'v')
                .addNumerical('chapter', 'c')
                .addNumerical('page', 'p')
                .duration()
                .build(),
          ),
        ],
      )
    );
  }
}


class BadgesBuilder {
  final HydrusFile _file;

  final List<Widget> _badges = [];

  BadgesBuilder(this._file);

  BadgesBuilder duration() {
    final duration = _file.meta.duration;
    if (duration == .zero) return this;

    final time = _stripZeros('$duration');
    _badges.add(Badge(label: time.n));

    return this;
  }

  static String _stripZeros(String duration) {
    final t = duration.split('.').first.split(':');
    if (t.first == '0') {
      t.removeAt(0);
      if (t.first == '00') t.first = '0';
    }
    return t.join(':');
  }

  BadgesBuilder addNumerical(String namespace, [String? prefix]) {
    final value = _file
        .tags.value.namespaces[namespace]?.first
        .replaceAll(RegExp(r'^0+'), '');
    if (value != null) _badges.add(Badge(label: '${prefix ?? ''}$value'.n));
    return this;
  }

  List<Widget> build() => _badges;
}


class InboxBadge extends StatelessWidget {
  final bool isInbox;

  const InboxBadge({super.key, required this.isInbox});

  @override
  Widget build(BuildContext context) {
    if (!isInbox) {
      return const SizedBox.shrink();
    }

    return Badge(
      label: Icon(
        Icons.mail_outline,
        color: Theme.of(context).colorScheme.onError,
        size: 12,
      ),
    );
  }
}
