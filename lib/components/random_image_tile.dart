
import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  const ImageTile({
    Key? key,
    required this.index,
    required this.width,
    required this.height,
    this.imageWidth = 100,
    this.image,
  }) : super(key: key);

  final int index;
  final int width;
  final int height;
  final double imageWidth;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          // color: Colors.grey,
          width: width.toDouble(),
          height: height.toDouble(),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Image.network(
            //ger random watch image
            // 'https://picsum.photos/$imageWidth/$imageWidth?random=$index',
            // 'https://picsum.photos/$width/$height?random=$index',
            // 'https://picsum.photos/id/${'watch'}/$width/$height',
            image ??
                'https://source.unsplash.com/random/${width}x$height/?wristwatch,$index',

            width: imageWidth.toDouble(),
            height: height.toDouble(),
            fit: BoxFit.cover,
          ),
        ),
        //   Positioned(
        //     bottom: 0,
        //     left: 0,
        //     right: 0,
        //     child: Container(
        //       color: Colors.black.withOpacity(0.5),
        //       padding: const EdgeInsets.all(8),
        //       child: Text(
        //         'Image $height',
        //         style: const TextStyle(
        //           color: Colors.white,
        //           fontSize: 24,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}
