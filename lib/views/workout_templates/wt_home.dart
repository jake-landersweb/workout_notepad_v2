import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
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
    return Column(
      children: [
        for (var item in data.entries)
          if (item.value.isNotEmpty)
            TemplateSection(
              title: item.key,
              templates: item.value,
            ),
      ],
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
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              child: PageView(
                children: [
                  for (int j = 0; j < 2; j++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LoadingWrapper(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cell(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 350,
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

class TemplateSection extends StatefulWidget {
  const TemplateSection({
    super.key,
    required this.title,
    required this.templates,
    this.trailingWidget,
  });
  final String title;
  final List<Workout> templates;
  final Widget? trailingWidget;

  @override
  State<TemplateSection> createState() => _TemplateSectionState();
}

class _TemplateSectionState extends State<TemplateSection> {
  late PageController _controller;
  late int _pageIndex;

  @override
  void initState() {
    _pageIndex = 0;
    _controller = PageController(initialPage: _pageIndex);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localTemplates = context.select(
      (DataModel value) => value.workoutTemplates,
    );

    return Column(
      children: [
        Section(
          widget.title,
          allowsCollapse: widget.trailingWidget == null,
          initOpen: true,
          trailingWidget: widget.trailingWidget,
          headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 350),
            child: PageView(
              controller: _controller,
              onPageChanged: (value) {
                setState(() {
                  _pageIndex = value;
                });
              },
              children: [
                for (var i in widget.templates)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: _workoutCell(context, i, localTemplates),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.templates.length; i++)
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
    );
  }

  Widget _workoutCell(
    BuildContext context,
    Workout template,
    List<Workout> localTemplates,
  ) {
    if (template is WorkoutTemplate) {
      var t = localTemplates
          .firstWhereOrNull((t) => t.workoutId == template.workoutId);
      return WorkoutCell(
        workout: t ?? template,
        allowActions: t != null,
        isTemplate: t == null,
        showBookmark: true,
        bookmarkFilled: t != null,
        isExpandedExercises: true,
      );
    } else {
      return WorkoutCell(workout: template, isExpandedExercises: true);
    }
  }
}
