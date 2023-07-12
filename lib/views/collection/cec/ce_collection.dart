// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/cec/root.dart';

class CECollection extends StatefulWidget {
  const CECollection({
    super.key,
    this.collection,
    this.onCreate,
  });
  final Collection? collection;
  final Function(Collection collection)? onCreate;

  @override
  State<CECollection> createState() => _CECollectionState();
}

class _CECollectionState extends State<CECollection> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);

    return ChangeNotifierProvider(
      create: (context) => CECModel(collection: widget.collection),
      builder: (context, _) => Navigator(
        onGenerateRoute: (settings) {
          return MaterialWithModalsPageRoute(
            settings: settings,
            builder: (context) => _body(context, dmodel),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    var cmodel = Provider.of<CECModel>(context);
    return InteractiveSheet(
      header: ((context) => _header(context, dmodel, cmodel)),
      builder: (context) {
        return PageView(
          controller: cmodel.pageController,
          onPageChanged: (index) {
            cmodel.setIndex(index);
          },
          children: const [
            CECBasic(),
            CECConfigure(),
            CECDetails(),
            CECPreview(),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context, DataModel dmodel, CECModel cmodel) {
    var isValid = cmodel.isValid();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CloseButton2(color: AppColors.subtext(context), useRoot: true),
            const Spacer(),
            Clickable(
              onTap: () async {
                if (!isValid.v1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isValid.v2),
                      backgroundColor: Colors.red[300],
                    ),
                  );
                } else {
                  setState(() {
                    _isLoading = true;
                  });
                  var response = await cmodel.create();
                  if (response.v1) {
                    await dmodel.refreshCategories();
                    if (widget.onCreate != null) {
                      widget.onCreate!(cmodel.collection);
                    }
                    Navigator.of(context, rootNavigator: true).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.v2),
                        backgroundColor: Colors.red[300],
                      ),
                    );
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              child: _isLoading
                  ? LoadingIndicator(
                      color: Theme.of(context).colorScheme.primary)
                  : Text(
                      cmodel.isCreate ? "Create" : "Save",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isValid.v1
                            ? AppColors.text(context)
                            : Colors.black.withOpacity(0.3),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // header
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _headerItem(
              context: context,
              cmodel: cmodel,
              title: "Basic",
              icon: LineIcons.dumbbell,
              index: 0,
            ),
            _divider(context),
            _headerItem(
              context: context,
              cmodel: cmodel,
              title: "Configure",
              icon: LineIcons.cog,
              index: 1,
            ),
            _divider(context),
            _headerItem(
              context: context,
              cmodel: cmodel,
              title: "Details",
              icon: LineIcons.fileInvoice,
              index: 2,
            ),
            _divider(context),
            _headerItem(
              context: context,
              cmodel: cmodel,
              title: "Preview",
              icon: LineIcons.image,
              index: 3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerItem({
    required BuildContext context,
    required CECModel cmodel,
    required String title,
    required IconData icon,
    required int index,
  }) {
    return Expanded(
      child: Clickable(
        onTap: () {
          cmodel.setPage(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: index <= cmodel.index
                    ? AppColors.cell(context)
                    : Colors.transparent,
                border: Border.all(color: AppColors.cell(context)),
                shape: BoxShape.circle,
              ),
              height: 50,
              width: 50,
              child: Center(
                child: Icon(
                  icon,
                  color: index <= cmodel.index
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.cell(context),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: AppColors.subtext(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        color: AppColors.cell(context),
        height: 0.5,
        width: 30,
      ),
    );
  }
}
