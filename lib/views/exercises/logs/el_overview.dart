import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ELOverview extends StatefulWidget {
  const ELOverview({super.key});

  @override
  State<ELOverview> createState() => _ELOverviewState();
}

class _ELOverviewState extends State<ELOverview> {
  final double pad = 16;

  @override
  Widget build(BuildContext context) {
    var elmodel = Provider.of<ELModel>(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          children: [
            Row(
              children: [
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.lineData?.spots.length.toString() ?? "-",
                    "Total Logs",
                  ),
                ),
              ],
            ),
            SizedBox(height: pad),
            Row(
              children: [
                _container(
                  context,
                  _basicBody(
                    context,
                    "${elmodel.lineData?.setHighFormatted() ?? '-'} ${elmodel.getPost()}",
                    "Max Weight",
                  ),
                ),
                SizedBox(width: pad),
                _container(
                  context,
                  _basicBody(
                    context,
                    "${elmodel.lineData?.setLowFormatted() ?? '-'} ${elmodel.getPost()}",
                    "Min Weight",
                  ),
                ),
              ],
            ),
            const ELRaw(),
          ],
        ),
      ),
    );
  }

  Widget _container(BuildContext context, Widget child, {double height = 100}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        height: height,
        child: Center(
          child: child,
        ),
      ),
    );
  }

  Widget _basicBody(BuildContext context, String title, String caption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          caption,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
