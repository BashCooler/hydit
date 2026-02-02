import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydrus_flutter/gallery/gallery.dart';
import 'package:hydrus_flutter/settings/theme.dart';
import 'package:hydrus_flutter/gallery/searchbar.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Consts.blackAlpha,
      // appBar: AppBar(backgroundColor: Colors.transparent),
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: Consts.blur, sigmaY: Consts.blur),
        child: AnimatedPadding(
          padding: EdgeInsetsGeometry.only(
            bottom: context.mediaQueryViewInsets.bottom,
          ),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Padding(
            padding: EdgeInsetsGeometry.all(Consts.searchPadding),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: .end,
                spacing: Consts.searchPadding,
                children: [
                  Suggests(),
                  TagPanel(clickable: false),
                  LiquidSearchBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
