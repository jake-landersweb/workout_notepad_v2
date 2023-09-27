// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/loading_indicator.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/account/root.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
              "Welcome Back!",
              style: ttTitle(context),
            ),
            Text(
              "Login to resume where you left off last time.",
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
                  hintText: "user@workoutnotepad.app",
                  keyboardType: TextInputType.emailAddress,
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
                  labelText: "Password",
                  onChanged: (_) {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            AccountButton(
              title: "Login",
              bg: Theme.of(context).colorScheme.primary,
              fg: AppColors.cell(context),
              isLoading: _isLoading,
              onTap: () async {
                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                if (_isLoading) {
                  return;
                }
                setState(() {
                  _isLoading = true;
                });
                await _logIn(context, dmodel);
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            // password reset
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
                        try {
                          print("Sending reset email");
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: _email.text.toLowerCase());
                          snackbarStatus(context,
                              "Success. Check your inbox for instructions on how to reset your password.");
                        } on FirebaseAuthException catch (e) {
                          print(e.message);
                          if (e.code == "auth/invalid-email") {
                            snackbarErr(context,
                                "The email was invalid. Do you have an account?");
                          } else {
                            snackbarErr(context, "There was an unknown error.");
                          }
                        } catch (e) {
                          print(e);
                          snackbarErr(context, "There was an unknown error.");
                        }
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
            AccountAuthButtons(
              onSignIn: (credential) async {
                await dmodel.loginUser(context, credential);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        if (dmodel.loadStatus == LoadStatus.init)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 50,
            width: 50,
            child: Center(
              child: LoadingIndicator(
                color: dmodel.color,
              ),
            ),
          )
      ],
    );
  }

  Future<void> _logIn(BuildContext context, DataModel dmodel) async {
    print("Attempting to login ...");
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _pass.text,
      );
      if (credential.user == null) {
        snackbarErr(context, "There was an issue getting your credentials.");
        setState(() {
          _isLoading = false;
        });
        return;
      }
      await NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "login_email",
        eventAttributes: {"userId": credential.user?.uid},
      );
      await dmodel.loginUser(context, credential);
      Navigator.of(context).pop();
      print("logged in");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        print('Your username or password was incorrect.');
        snackbarErr(context, "Your username or password was incorrect.");
      } else {
        print(e.code);
        snackbarErr(context, "There was an unknown error: ${e.code}");
      }
    } catch (e) {
      print(e);
      snackbarErr(context, "There was an unknown error.");
    }
  }
}
