import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class StoreScreenshot extends StatelessWidget {
  const StoreScreenshot({
    super.key,
    required this.size,
    required this.text,
    required this.deviceImage,
  });
  final StoreScreenShotSize size;
  final String text;
  final MemoryImage deviceImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: ColorUtil.random(text),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(40, 40, 40, 0),
                    child: Center(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.08,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          color: getSwatch(ColorUtil.random(text))[800],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Image(
                      image: deviceImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoreScreenShotSize {
  const StoreScreenShotSize({
    required this.width,
    required this.height,
  });
  final double width;
  final double height;

  static iphoneLarge() => StoreScreenShotSize(width: 1284, height: 2778);
  static iphoneSmall() => StoreScreenShotSize(width: 1242, height: 2208);
}
