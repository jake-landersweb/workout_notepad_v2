import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/model/workout_template_model.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workout_templates/wt_cell.dart';

class DiscoverHome extends StatefulWidget {
  const DiscoverHome({super.key});

  @override
  State<DiscoverHome> createState() => _DiscoverHomeState();
}

class _DiscoverHomeState extends State<DiscoverHome> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTemplateModel>(
      builder: (context, model, child) {
        return HeaderBar(
          isLarge: true,
          title: "Discover",
          refreshable: true,
          onRefresh: () async {
            await fetchData(reload: true);
          },
          children: [
            const SizedBox(height: 16),
            if (model.loadingRemoteTemplates)
              const LoadingIndicator()
            else if (model.remoteTemplates == null ||
                model.remoteTemplates!.isEmpty)
              const Text("No templates found")
            else
              _body(context, model.remoteTemplates!),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, List<WorkoutTemplate> templates) {
    return Column(
      children: [
        for (var i in templates) WTCell(wt: i),
      ],
    );
  }

  Future<void> fetchData({bool reload = false}) async {
    try {
      var model = context.read<WorkoutTemplateModel>();
      await model.fetchRemoteTemplates(reload: reload);
    } catch (error, stack) {
      print(error);
      print(stack);
      snackbarErr(context, "Failed to get the remote workout templates.");
    }
  }
}
