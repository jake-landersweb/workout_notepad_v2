// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/category.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/status/empty.dart';
import 'package:workout_notepad_v2/views/status/error.dart';
import 'package:workout_notepad_v2/views/workout_templates/workout_template_model.dart';
import 'package:workout_notepad_v2/views/workouts/workout_cell.dart';

extension WorkoutTemplateSearch on WorkoutTemplateModel {
  Widget header({
    required BuildContext context,
    required DataModel dmodel,
  }) {
    return Column(
      children: [
        CellWrapper(
          backgroundColor: AppColors.cell(context),
          border: Border.all(color: AppColors.border(context), width: 3),
          child: Row(
            children: [
              Icon(
                LineIcons.search,
                color: AppColors.subtext(context),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Field(
                  labelText: "",
                  hintText: "Search remote templates ...",
                  hasClearButton: true,
                  controller: textEditingController,
                  onChanged: (v) {
                    notifyListeners();
                  },
                ),
              )
            ],
          ),
        ),
        Section(
          "Filters",
          allowsCollapse: true,
          initOpen: categories.isNotEmpty,
          headerPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < dmodel.categories.length; i++)
                    _categoryCell(context, dmodel.categories[i]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryCell(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () {
        if (categories.any((element) => element == category.categoryId)) {
          categories.removeWhere((element) => element == category.categoryId);
        } else {
          categories.add(category.categoryId);
        }
        searchRemoteTemplates(reload: true);
        notifyListeners();
      },
      child: Container(
        decoration: BoxDecoration(
          color: categories.contains(category.categoryId)
              ? Theme.of(context).colorScheme.primary
              : AppColors.cell(context),
          borderRadius: BorderRadius.circular(100),
        ),
        height: 40,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category.icon != "")
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: getImageIcon(category.icon, size: 25),
                ),
              Text(
                category.title.capitalize(),
                style: TextStyle(
                  color: categories.contains(category.categoryId)
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WTSearch extends StatefulWidget {
  const WTSearch({super.key});

  @override
  State<WTSearch> createState() => _WTSearchState();
}

class _WTSearchState extends State<WTSearch> {
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
    var dmodel = context.watch<DataModel>();
    return Scaffold(
      body: Consumer<WorkoutTemplateModel>(
        builder: (context, model, child) {
          return HeaderBar(
            isLarge: false,
            title: "Search",
            refreshable: true,
            onRefresh: () async {
              await fetchData(reload: true);
            },
            leading: [
              BackButton2(),
            ],
            children: [
              const SizedBox(height: 16),
              model.header(
                context: context,
                dmodel: dmodel,
              ),
              const SizedBox(height: 32),
              _build(context, model),
            ],
          );
        },
      ),
    );
  }

  Widget _build(BuildContext context, WorkoutTemplateModel model) {
    switch (model.searchTemplateStatus) {
      case LoadingStatus.loading:
        return _loading();
      case LoadingStatus.error:
        return const ErrorScreen(
          title: "There was an issue getting the templates.",
        );
      case LoadingStatus.done:
        if (model.remoteTemplates == null || model.remoteTemplates!.isEmpty) {
          return const EmptyScreen(title: "No templates found.");
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
        for (var i in templates)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _workoutCell(context, i, localTemplates),
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
        for (int j = 0; j < 2; j++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 32,
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
    );
  }

  Future<void> fetchData({bool reload = false}) async {
    try {
      var model = context.read<WorkoutTemplateModel>();
      await model.searchRemoteTemplates(reload: reload);
    } catch (error, stack) {
      logger.exception(error, stack);
      snackbarErr(context, "Failed to get the remote workout templates.");
    }
  }
}
