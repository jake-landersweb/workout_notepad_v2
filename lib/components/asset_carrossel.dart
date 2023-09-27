import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class PhoneAssetCarrossel extends StatefulWidget {
  const PhoneAssetCarrossel({
    super.key,
    required this.assets,
    this.titles,
    this.radius = 26,
    this.startIndex = 0,
    this.heightFactor = 0.5,
  });
  final List<String> assets;
  final List<String>? titles;
  final double radius;
  final int startIndex;
  final double heightFactor;

  @override
  State<PhoneAssetCarrossel> createState() => _PhoneAssetCarrosselState();
}

class _PhoneAssetCarrosselState extends State<PhoneAssetCarrossel> {
  late PageController _controller;
  late int _pageIndex;

  @override
  void initState() {
    if (widget.titles != null) {
      assert(widget.titles!.length == widget.assets.length,
          "titles and asset length must be the same");
    }
    _pageIndex = widget.startIndex;
    _controller = PageController(initialPage: _pageIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * widget.heightFactor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (value) {
                setState(() {
                  _pageIndex = value;
                });
              },
              children: [
                for (int i = 0; i < widget.assets.length; i++)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.titles != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              widget.titles![i],
                              style: ttLabel(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                                  BorderRadius.circular(widget.radius),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(widget.assets[i]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.assets.length; i++)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: i == _pageIndex
                          ? AppColors.subtext(context)
                          : AppColors.light(context),
                      shape: BoxShape.circle,
                    ),
                    height: 7,
                    width: 7,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
