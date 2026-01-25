import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrus_flutter/theme.dart';
import 'package:hydrus_flutter/pages/settings.dart';
import 'package:hydrus_flutter/widgets/images.dart';

import '../api/hydrus.dart';
import '../api/hydrus_ui.dart';
import '../main.dart';
import '../widgets/gridview.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  List<HydrusImage> images = [];
  late Client client;
  late var _clientFuture = createClientWithSettings().then((v) => client = v);

  void updateClient() {
    _clientFuture = createClientWithSettings().then((v) => client = v);
  }

  void searchForFiles(List<String> tags) async {

    // TODO tag chips see: https://api.flutter.dev/flutter/material/Chip-class.html

    List<int> ids = [];
    try {
      ids = await client.getSearchFiles(tags);
    } on HydrusNoServiceException {
      showSnackBar('No connection with Hydrus');
    } on HydrusTimeoutException {
      showSnackBar('No response (timeout)');
    }

    final images = ids.map((id) => HydrusImage(id)).toList();

    setState(() => this.images = images);
  }

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Hydrus Client'),
        actions: [
          IconButton(
            onPressed: () => _openSettings(context),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: FutureBuilder(future: _clientFuture, builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Stack(
            alignment: .bottomCenter,
            children: [
              ImageGridViewBuilder(images, client),
              AnimatedLiquidSearchBar(onSearch: (s) => searchForFiles([s])),
            ],
          );
        }
        return Center(child: CircularProgressIndicator());
      }),
    );
  }

  // MARK: SNACKBAR

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: RepaintBoundary(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: Consts.blur, sigmaY: Consts.blur),
            child: Text(message),
          ),
        ),
        backgroundColor: Consts.blackAlpha,
      ),
      snackBarAnimationStyle: AnimationStyle(
        curve: Curves.easeInExpo,
        reverseCurve: Curves.easeOutExpo,
        duration: Duration(milliseconds: 1000),
        reverseDuration: Duration(milliseconds: 1000),
      ),
    );
  }

  // MARK: SETTINGS

  void _openSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsPage()),
    );
    updateClient();
  }
}

class AnimatedLiquidSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const AnimatedLiquidSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<AnimatedLiquidSearchBar> createState() => _AnimatedLiquidSearchBarState();
}

class _AnimatedLiquidSearchBarState extends State<AnimatedLiquidSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0.8),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchVisibilityCubit, SearchVisibility>(
      builder: (BuildContext context, SearchVisibility state) {
        if (state == SearchVisibility.visible) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
        return SlideTransition(
          position: _slide,
          child: LiquidSearchBar(onSearch: widget.onSearch),
        );
      },
    );
  }
}

class LiquidSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const LiquidSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(Consts.radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: Consts.blur, sigmaY: Consts.blur),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                hintText: 'Search',
                fillColor: Consts.blackAlpha,
              ),
              onSubmitted: onSearch,
            ),
          ),
        ),
      ),
    );
  }
}