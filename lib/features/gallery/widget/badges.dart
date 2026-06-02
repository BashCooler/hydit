import 'package:flutter/material.dart';
import 'package:hydit/reactive/file.dart';
import 'package:niku/extra/primitive.dart';



class TileBadges extends StatelessWidget {
  final HydrusFile file;

  const TileBadges(this.file, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(8.0),
      child: Wrap(
        alignment: .end,
        spacing: 2,
        runSpacing: 2,
        children: BadgesBuilder(file)
            .duration()
            .addNumerical('volume', 'v')
            .addNumerical('chapter', 'c')
            .addNumerical('page', 'p')
            .build(),
      ),
    );
  }
}


class BadgesBuilder {
  final HydrusFile _file;

  final List<Widget> _badges = [];

  BadgesBuilder(this._file);

  BadgesBuilder duration() {
    if (_file.loading) return this;

    final duration = _file.meta!.duration;
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
        .meta!.namespaces[namespace]?.first
        .replaceAll(RegExp(r'^0+'), '');
    if (value != null) _badges.add(Badge(label: '${prefix ?? ''}$value'.n));
    return this;
  }

  List<Widget> build() => _badges;
}