import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/model/workout_template_model.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class WTHome extends StatefulWidget {
  const WTHome({super.key});

  @override
  State<WTHome> createState() => _WTHomeState();
}

class _WTHomeState extends State<WTHome> {
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
            _build(context, model),
          ],
        );
      },
    );
  }

  Widget _build(BuildContext context, WorkoutTemplateModel model) {
    switch (model.remoteTemplateStatus) {
      case LoadingStatus.loading:
        return const LoadingIndicator();
      case LoadingStatus.error:
        // TODO: add a better error screen
        return const Text("There was an error");
      case LoadingStatus.done:
        if (model.remoteTemplates == null || model.remoteTemplates!.isEmpty) {
          // TODO: add a better empty screen
          return const Text("No templates found");
        } else {
          return _body(context, model.remoteTemplates!);
        }
    }
  }

  Widget _body(BuildContext context, List<WorkoutTemplate> templates) {
    var localTemplates = context.select(
      (DataModel value) => value.workoutTemplates,
    );

    return Column(
      children: [
        for (var i in templates) _workoutCell(context, i, localTemplates),
      ],
    );
  }

  Widget _workoutCell(
    BuildContext context,
    WorkoutTemplate template,
    List<WorkoutTemplate> localTemplates,
  ) {
    var t = localTemplates.firstWhereOrNull((t) => t.id == template.id);
    return WorkoutCell(
      workout: t ?? template,
      allowActions: t != null,
      isTemplate: t == null,
      showBookmark: true,
      bookmarkFilled: t != null,
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
