import 'package:flutter/material.dart';

import 'package:hydrus_flutter/hydrus_api/hydrus.dart';
import 'package:hydrus_flutter/pages/image_view.dart';
import 'images.dart';


class ImageGridViewBuilder extends StatefulWidget {
  final List<int> ids;
  final Client client;
  late final List<HydrusImage> images = ids.map((id) => HydrusImage(id)).toList();

  ImageGridViewBuilder(this.ids, this.client, {super.key});

  @override
  State<ImageGridViewBuilder> createState() => _ImageGridViewBuilderState();
}

class _ImageGridViewBuilderState extends State<ImageGridViewBuilder> {
  final padding = 5.0;

  @override
  Widget build(BuildContext context) {
    final ids = widget.ids;
    final images = widget.images;
    final client = widget.client;
    return GridView.builder(
      itemCount: ids.length,
      padding: EdgeInsetsGeometry.all(padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: padding,
        crossAxisSpacing: padding,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ImageView(
              images: images,
              index: index,
              client: client,
            )));
          },
          child: Hero(
            tag: images[index].id,
            createRectTween: (begin, end) {  // linear transition
              return RectTween(begin: begin, end: end);
            },
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Thumbnail(image: images[index], client: client),
            ),
          ),
        );
      },
    );
  }
}