// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/color_schemes.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/logger/events/navigation.dart';
import 'package:workout_notepad_v2/model/internet_provider.dart';
import 'package:workout_notepad_v2/model/local_prefs.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/model/search_model.dart';
import 'package:workout_notepad_v2/otel.dart';
import 'package:workout_notepad_v2/views/workout_templates/workout_template_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/functions.dart';
import 'package:workout_notepad_v2/views/account/anon_create.dart';
import 'package:workout_notepad_v2/views/account/root.dart';
import 'package:workout_notepad_v2/views/home.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // init the global telemetry provider
      await GlobalTelemetry.initialize();

      runApp(MyApp(
        defaultUser: kDebugMode
            ? '{"userId": "xL3zGrTtKYZp8ml6QiDDFmDu86w2", "displayName": "Jake Landers"}'
            : null,
      ));
    },
    (Object error, StackTrace stackTrace) {
      logger.exception(
        error,
        stackTrace,
        message: "failed to launch the app",
      );
    },
    zoneSpecification: ZoneSpecification(
      // override the default printer to re-direct to the logger
      print: (self, parent, zone, line) {
        logger.parse(line);
      },
    ),
  );
}

// for allowing absoute reset when needed
class RestartWidget extends StatefulWidget {
  const RestartWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.defaultUser,
  });
  final String? defaultUser;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return const TestWidget();
    return RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => DataModel(defaultUser: defaultUser),
          ),
          ChangeNotifierProvider(create: (context) => SearchModel()),
          ChangeNotifierProvider(create: (context) => WorkoutTemplateModel()),
          ChangeNotifierProvider(create: (context) => InternetProvider()),
          ChangeNotifierProvider(create: (context) => LocalPrefs()),
        ],
        builder: (context, child) {
          return _body(context);
        },
      ),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    // init the local prefs
    var _ = context.watch<LocalPrefs>();
    final scheme = AppColorScheme(primaryColor: dmodel.color);
    return GestureDetector(
      onTap: () {
        // for dismissing keybaord when tapping on the screen
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        child: MaterialApp(
          title: 'Workout Notepad',
          debugShowCheckedModeBanner: false,
          theme: scheme.getTheme(context, Brightness.light),
          navigatorObservers: [NavigationLoggingObserver(logger)],
          onGenerateRoute: (settings) {
            return MaterialWithModalsPageRoute(
              settings: settings,
              builder: (context) => const Index(),
            );
          },
        ),
      ),
    );
  }
}

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> with WidgetsBindingObserver {
  DateTime? _closedTime;
  bool showedUpdate = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        DataModel dmodel = Provider.of<DataModel>(context, listen: false);

        // check if enough time has passed
        if ((_closedTime?.isBefore(
                DateTime.now().subtract(const Duration(minutes: 30)))) ??
            false) {
          // do not fuck with workout states
          if (dmodel.workoutState == null) {
            // fetch the user information
            dmodel.getUser();
          }
        }

        break;
      case AppLifecycleState.inactive:

        // dump current workout state to a tmp file if the user ends up closing the app
        DataModel dmodel = Provider.of<DataModel>(context, listen: false);
        if (dmodel.workoutState != null) {
          // create a snapshot of this workout state
          dmodel.workoutState!.dumpToFile();
        }

        break;
      case AppLifecycleState.paused:

        // keep track of time when to re-load the app
        _closedTime = DateTime.now();

        break;
      case AppLifecycleState.detached:
        // app is closing
        logger.flush();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);

    if (!showedUpdate) {
      if (dmodel.showForcedUpdate) {
        return Scaffold(
          body: HeaderBar(
            title: "Required Update",
            isLarge: true,
            children: [
              const SizedBox(height: 16),
              Text(
                "There is a required update for Workout Notepad.",
                style: ttLabel(context),
              ),
              const SizedBox(height: 8),
              Text(
                "We appologize for any inconveniences this may cause.",
                style: ttcaption(context),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 2,
                ),
                child: SvgPicture.asset(
                  "assets/svg/workout.svg",
                  semanticsLabel: 'Workout Logo',
                ),
              ),
              WrappedButton(
                title: "Update now",
                type: WrappedButtonType.main,
                center: true,
                onTap: () {
                  launchAppStore();
                },
              ),
            ],
          ),
        );
      } else if (dmodel.showRecommendedUpdate) {
        showedUpdate = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlert(
            context: context,
            title: "Update Available",
            body: const Text(
                "There is a recommended update available for Workout Notepad. Would you like to update?"),
            cancelText: "Not Now",
            onCancel: () {},
            submitBolded: true,
            submitText: "Update",
            onSubmit: () async {
              launchAppStore();
            },
          );
        });
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: _body(context, dmodel),
      ),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    switch (dmodel.loadStatus) {
      case LoadStatus.init:
        return const CircularProgressIndicator();
      case LoadStatus.noUser:
        return const AccountInit();
      case LoadStatus.done:
        return const Home();
      // return LogsCatIndiv2(category: dmodel.categories[6]);
      case LoadStatus.expired:
        return const AnonCreateAccount();
    }
  }
}
