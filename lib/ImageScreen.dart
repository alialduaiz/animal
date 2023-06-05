import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageFullScreen extends StatelessWidget {
  final String imageUrl;

  ImageFullScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image View'),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            onPressed: () async {
              await _saveImage(context);
            },
          ),
        ],
      ),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    var response = await http.get(Uri.parse(imageUrl));
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.bodyBytes));

    if (result['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Image saved successfully'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save image'),
      ));
    }
  }
}

