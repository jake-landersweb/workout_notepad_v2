import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/account/root.dart';
import 'package:workout_notepad_v2/views/account/singin_apple.dart';

class AccountTemplate extends StatefulWidget {
  const AccountTemplate({
    super.key,
    required this.title,
    required this.description,
    this.emailPassButtonTitle = "Login",
    required this.onEmailCallback,
    required this.onAppleCallback,
    required this.onGoogleCallback,
    this.onForgotPass,
  });
  final String title;
  final String description;
  final String emailPassButtonTitle;
  final Future<String> Function(String email, String pass) onEmailCallback;
  final Future<String> Function() onAppleCallback;
  final Future<String> Function() onGoogleCallback;
  final Future<String> Function(String email)? onForgotPass;

  @override
  State<AccountTemplate> createState() => _AccountTemplateState();
}

class _AccountTemplateState extends State<AccountTemplate> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        comp.HeaderBar.sheet(
          title: "",
          leading: const [comp.CloseButton2()],
          children: [
            Text(
              widget.title,
              style: ttTitle(context),
            ),
            Text(
              widget.description,
              style: ttLabel(
                context,
                color: AppColors.subtext(context),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cell(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: comp.Field(
                  controller: _email,
                  hintText: "user@workoutnotepad.co",
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  labelText: "Email",
                  onChanged: (v) {
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cell(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: comp.Field(
                  controller: _pass,
                  hintText: "******",
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.none,
                  labelText: "Password",
                  onChanged: (_) {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            AccountButton(
              title: widget.emailPassButtonTitle,
              bg: Theme.of(context).colorScheme.primary,
              fg: AppColors.cell(context),
              isLoading: _isLoading || dmodel.loadStatus == LoadStatus.init,
              onTap: () async {
                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                if (_isLoading) {
                  return;
                }
                if (_email.text == "" || _pass.text == "") {
                  snackbarErr(
                      context, "The email and password cannot be empty");
                  return;
                }
                setState(() {
                  _isLoading = true;
                });
                var response =
                    await widget.onEmailCallback(_email.text, _pass.text);
                if (response.isNotEmpty) {
                  snackbarErr(context, response);
                } else {
                  Navigator.of(context).pop();
                }
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            // password reset
            if (widget.onForgotPass != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Clickable(
                    onTap: () async {
                      await showAlert(
                        context: context,
                        title: "Send Reset Link?",
                        body: const Text(
                            "Do you want to send a reset link to the email specified?"),
                        cancelText: "Cancel",
                        onCancel: () {},
                        submitText: "Send Email",
                        onSubmit: () async {
                          if (_email.text.isEmpty) {
                            snackbarErr(context, "Your email is invalid.");
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                          });
                          var response =
                              await widget.onForgotPass!(_email.text);
                          if (response.isNotEmpty) {
                            snackbarErr(context, response);
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        },
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: ttBody(
                        context,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            SigninGoogle(
              onSignIn: () async {
                if (_isLoading) return;
                setState(() {
                  _isLoading = true;
                });
                var response = await widget.onGoogleCallback();
                if (response.isNotEmpty) {
                  snackbarErr(context, response);
                } else {
                  Navigator.of(context).pop();
                }
                setState(() {
                  _isLoading = false;
                });
              },
              isLoading: _isLoading || dmodel.loadStatus == LoadStatus.init,
            ),
            const SizedBox(height: 8),
            if (Platform.isIOS)
              SigninApple(
                onSignIn: () async {
                  if (_isLoading) return;
                  setState(() {
                    _isLoading = true;
                  });
                  var response = await widget.onAppleCallback();
                  if (response.isNotEmpty) {
                    snackbarErr(context, response);
                  } else {
                    Navigator.of(context).pop();
                  }
                  setState(() {
                    _isLoading = false;
                  });
                },
                isLoading: _isLoading || dmodel.loadStatus == LoadStatus.init,
              ),
          ],
        ),
      ],
    );
  }
}
