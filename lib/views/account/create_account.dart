import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/account/root.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var dmodel = context.read<DataModel>();
    return comp.HeaderBar.sheet(
      title: "",
      leading: const [comp.CloseButton()],
      children: [
        Text(
          "One Step Away From Fitness Planning.",
          style: ttTitle(context),
        ),
        Text(
          "Complete the sign-up process below to get started.",
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
          title: "Create Account",
          bg: Theme.of(context).colorScheme.primary,
          fg: AppColors.cell(context),
          isLoading: _isLoading,
          onTap: () async {
            if (!_isLoading) {
              setState(() {
                _isLoading = true;
              });
              await _action(context, dmodel);
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
        AccountAuthButtons(
          onSignIn: (credential) async {
            await dmodel.loginUser(context, credential);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<void> _action(BuildContext context, DataModel dmodel) async {
    print("Attempting to create account ...");
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _pass.text,
      );
      if (credential.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[200],
            content: const Text(
              "There was an issue getting your credentials",
            ),
          ),
        );
        return;
      }
      await dmodel.loginUser(context, credential);
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[300],
            content: const Text("Your password is too weak."),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[200],
            content: const Text("An account already exists for that email."),
          ),
        );
      } else if (e.code == "invalid-email") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[200],
            content: const Text("Invalid email."),
          ),
        );
      } else {
        print(e.code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[300],
            content: Text("There was an unknown error: ${e.code}"),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}