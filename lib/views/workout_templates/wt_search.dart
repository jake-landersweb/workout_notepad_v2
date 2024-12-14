// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:workout_notepad_v2/components/cell_wrapper.dart';
import 'package:workout_notepad_v2/components/field.dart';
import 'package:workout_notepad_v2/components/section.dart';
import 'package:workout_notepad_v2/data/category.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workout_templates/workout_template_model.dart';

extension WorkoutTemplateSearch on WorkoutTemplateModel {
  Widget header({
    required BuildContext context,
    required DataModel dmodel,
  }) {
    return Column(
      children: [
        CellWrapper(
          backgroundColor: AppColors.cell(context),
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
        fetchRemoteTemplates(reload: true);
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
