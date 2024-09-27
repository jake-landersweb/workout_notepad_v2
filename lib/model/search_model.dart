import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:workout_notepad_v2/components/cell_wrapper.dart';
import 'package:workout_notepad_v2/components/field.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/icons.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class SearchModel extends ChangeNotifier {
  late TextEditingController _controller;

  SearchModel() {
    _controller = TextEditingController();
  }

  final List<String> _categories = [];
  ExerciseType? _type;

  List<Exercise> search(List<Exercise> input) {
    // if no filters, return input
    if (_categories.isEmpty && _type == null && _controller.text.isEmpty) {
      return input;
    }

    // multiple levels of filtering
    Iterable<Exercise> items = input;

    if (_categories.isNotEmpty) {
      items = items.where((element) => _categories.contains(element.category));
    }
    if (_type != null) {
      items = items.where((element) => element.type == _type);
    }
    if (_controller.text.isNotEmpty) {
      items = items.where((element) =>
          element.title
              .toLowerCase()
              .contains(_controller.text.toLowerCase()) ||
          (element.description.isNotEmpty &&
              element.description
                  .toLowerCase()
                  .contains(_controller.text.toLowerCase())));
    }

    return items.toList();
  }

  Widget header({
    required BuildContext context,
    required DataModel dmodel,
    required String labelText,
    String? hintText,
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
                  labelText: labelText,
                  hintText: hintText ?? labelText,
                  hasClearButton: true,
                  controller: _controller,
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
          initOpen: _categories.isNotEmpty || _type != null,
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
              const SizedBox(height: 8),
              DynamicGridView(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ExerciseType.values.length,
                builder: (context, i) {
                  var t = ExerciseType.values[i];
                  return Clickable(
                    onTap: () {
                      if (_type == t) {
                        _type = null;
                      } else {
                        _type = t;
                      }
                      notifyListeners();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            _type == t ? dmodel.color : AppColors.cell(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                exerciseTypeIcon(t),
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                exerciseTypeTitle(t),
                                style: TextStyle(
                                    color: _type == t
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
        if (_categories.any((element) => element == category.categoryId)) {
          _categories.removeWhere((element) => element == category.categoryId);
        } else {
          _categories.add(category.categoryId);
        }
        notifyListeners();
      },
      child: Container(
        decoration: BoxDecoration(
          color: _categories.contains(category.categoryId)
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
                  color: _categories.contains(category.categoryId)
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
