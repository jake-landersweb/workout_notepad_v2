import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/user.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/image.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({
    super.key,
    required this.user,
    required this.onSave,
  });
  final User user;
  final VoidCallback onSave;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _isLoading = false;

  AppFile? _file;
  bool _changedImg = false;

  late String _name;

  @override
  void initState() {
    super.initState();
    if (widget.user.imgUrl != null && widget.user.imgUrl != "") {
      if (widget.user.imgUrl!.contains("http")) {
        _handleUrl(widget.user.imgUrl!);
      }
    }
    _name = widget.user.getName();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) => _body(context),
        );
      },
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "Edit Profile",
      leading: const [
        CancelButton(
          useRoot: true,
        )
      ],
      trailing: [
        Clickable(
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            var response = await _save(context, dmodel);
            if (response) {
              await dmodel.getUser();
              widget.onSave();
              Navigator.of(context, rootNavigator: true).pop();
            }
            setState(() {
              _isLoading = true;
            });
          },
          child: _isLoading
              ? const LoadingIndicator()
              : Text(
                  "Save",
                  style: ttLabel(
                    context,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
        ),
      ],
      children: [
        const SizedBox(height: 16),
        Clickable(
          onTap: () => _selectMedia(context),
          child: _file == null
              ? SizedBox(
                  height: 150,
                  width: 150,
                  child: Align(
                    child: widget.user.avatar(context, size: 150),
                  ),
                )
              : SizedBox(
                  height: 150,
                  width: 150,
                  child: Align(
                    child: ClipOval(
                      child: Image(
                        image: FileImage(_file!.file!),
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              "Note, the image on your profile may be cached as the old value until a new app launch.",
              style: ttcaption(context, fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Field(
              labelText: "Name",
              hintText: "Display Name",
              value: _name,
              onChanged: (v) {
                setState(() {
                  _name = v;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: SelectableText(
            "userId: ${widget.user.userId}",
            style: ttcaption(
              context,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleUrl(String url) async {
    // create the file
    var file = await AppFile.fromUrl(
        objectId: "${widget.user.userId}_profile", url: url);

    if (file == null) {
      print("err");
      return;
    }

    setState(() {
      _file = file;
    });
  }

  Future<void> _selectMedia(BuildContext context) async {
    await promptMedia(
      context: context,
      allowsVideo: false,
      onSelected: (f) {
        if (f == null) {
          snackbarErr(context, "There was an issue selecting the image");
          return;
        }
        _changedImg = true;
        _file ??= AppFile.init(objectId: "${widget.user.userId}_profile");
        setState(() {
          _file!.setFile(file: f);
        });
      },
    );
  }

  Future<bool> _save(BuildContext context, DataModel dmodel) async {
    try {
      // https://lh3.googleusercontent.com/a/AAcHTte7wh2qdSKHhHQYjVYlBVY3L3bZg3b5d1D3gIVUKJVGd58=s96-c

      // create the body
      Map<String, dynamic> body = {
        "displayName": _name,
      };

      // upload the file if applicable
      if (_changedImg && _file != null) {
        if (await _file!.upload(widget.user.userId)) {
          body['imgUrl'] = _file!.filename;
        }
      }

      if (body.isNotEmpty) {
        var response = await dmodel.purchaseClient.put(
          "/users/${widget.user.userId}",
          {},
          jsonEncode(body),
        );
        if (response.statusCode != 200) {
          print(response.body);
          return false;
        }
        if (_changedImg) {
          _file!.ejectFromCache();
        }
        snackbarStatus(context, "Successfully updated your profile");
      } else {
        print("No changes to make");
      }
      return true;
    } catch (e, stack) {
      print(e);
      print(stack);
      return false;
    }
  }
}
