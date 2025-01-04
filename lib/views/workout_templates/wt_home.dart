import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/status/error.dart';
import 'package:workout_notepad_v2/views/workout_templates/workout_template_model.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workout_templates/wt_search.dart';

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
          horizontalSpacing: 0,
          largeTitlePadding: EdgeInsets.only(left: 16),
          onRefresh: () async {
            await fetchData(reload: true);
          },
          trailing: [
            Clickable(
              onTap: () {
                navigate(context: context, builder: (context) => WTSearch());
              },
              child: Icon(
                LineIcons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
              child: Text(
                "Custom, tailor-made workout templates from experts for you.",
                style: ttLabel(context, color: AppColors.subtext(context)),
              ),
            ),
            _build(context, model),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _build(BuildContext context, WorkoutTemplateModel model) {
    switch (model.homeTemplateStatus) {
      case LoadingStatus.loading:
        return _loading();
      case LoadingStatus.error:
        return const ErrorScreen(
          title: "There was an issue getting the templates.",
        );
      case LoadingStatus.done:
        return _body(context, model.homepageData!);
    }
  }

  Widget _body(BuildContext context, Map<String, List<WorkoutTemplate>> data) {
    var localTemplates = context.select(
      (DataModel value) => value.workoutTemplates,
    );

    return Column(
      children: [
        for (var item in data.entries)
          if (item.value.isNotEmpty)
            Section(
              item.key,
              allowsCollapse: true,
              initOpen: true,
              headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    for (var i in item.value)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width - 32 - 32,
                          ),
                          child: _workoutCell(context, i, localTemplates),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _workoutCell(
    BuildContext context,
    WorkoutTemplate template,
    List<WorkoutTemplate> localTemplates,
  ) {
    var t = localTemplates
        .firstWhereOrNull((t) => t.workoutId == template.workoutId);
    return WorkoutCell(
      workout: t ?? template,
      allowActions: t != null,
      isTemplate: t == null,
      showBookmark: true,
      bookmarkFilled: t != null,
    );
  }

  Widget _loading() {
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          Section(
            "",
            allowsCollapse: true,
            initOpen: true,
            headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            loading: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  for (int j = 0; j < 2; j++)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 32 - 32,
                        ),
                        child: LoadingWrapper(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.cell(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 250,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> fetchData({bool reload = false}) async {
    try {
      var model = context.read<WorkoutTemplateModel>();
      await model.getHomepageData(reload: reload);
    } catch (error, stack) {
      print(error);
      print(stack);
      snackbarErr(context, "Failed to get the remote workout templates.");
    }
  }
}
