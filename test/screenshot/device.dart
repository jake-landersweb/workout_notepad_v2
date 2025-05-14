import 'dart:typed_data';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart' as img;
import 'package:workout_notepad_v2/components/loading_indicator.dart';

// Wraps a raw screenshot in a device
Widget wrapInDevice(Uint8List data, MediaQueryData mediaQuery) {
  final memoryImage = MemoryImage(data);
  final image = Image(image: memoryImage);

  return Device(
    mediaQuery: mediaQuery,
    child: image,
  );
}

Uint8List cropSafeArea(Uint8List data, int top, int bottom) {
  final image = img.decodeImage(data)!;
  return Uint8List.fromList(
    img.encodePng(
      img.copyCrop(
        image,
        x: 0,
        y: top,
        width: image.width,
        height: image.height - top - bottom,
      ),
    ),
  );
}

class Device extends StatelessWidget {
  final Widget child;
  final MediaQueryData mediaQuery;

  const Device({
    super.key,
    required this.child,
    required this.mediaQuery,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: mediaQuery,
      child: Builder(builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            DeviceFrame(
              device: Devices.ios.iPhone13,
              isFrameVisible: true,
              orientation: Orientation.portrait,
              screen: child,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: const FakeStatusBar(time: "9:41"),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 5,
                    width: MediaQuery.of(context).size.width / 3,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
    // return ClipPath(
    //   clipper: InfiniteCornerClipper(borderRadius + borderWidth),
    //   child: Container(
    //     color: borderColor,
    //     padding: EdgeInsets.all(borderWidth),
    //     child: ClipPath(
    //       clipper: InfiniteCornerClipper(borderRadius),
    //       child: Stack(
    //         alignment: Alignment.topCenter,
    //         children: [
    //           child,
    //           const FakeStatusBar(time: "9:41"),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}

class FakeStatusBar extends StatelessWidget {
  final String time;

  const FakeStatusBar({
    super.key,
    this.time = "9:41", // Default iPhone time
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, // Adjust to match the status bar height
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time
          Text(
            time,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          SvgPicture.asset(
            "assets/svg/ios-battery-full-3.svg",
            height: 26,
            width: 26,
            fit: BoxFit.fitHeight,
            placeholderBuilder: (context) {
              return LoadingIndicator();
            },
          ),
        ],
      ),
    );
  }
}

class InfiniteCornerClipper extends CustomClipper<Path> {
  final double cornerRadius;

  InfiniteCornerClipper(this.cornerRadius);

  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = cornerRadius;

    // Top-left corner
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Top-right corner
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Bottom-right corner
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);

    // Bottom-left corner
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
