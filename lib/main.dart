import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:newrelic_mobile/config.dart';
import 'package:newrelic_mobile/newrelic_navigation_observer.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/color_schemes.dart';
import 'package:workout_notepad_v2/env.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/account/root.dart';
import 'package:workout_notepad_v2/views/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';

void main() async {
  var appToken = "";
  if (Platform.isIOS) {
    appToken = NR_TOKEN_IOS;
  } else if (Platform.isAndroid) {
    appToken = NR_TOKEN_ANDROID;
  }

  Config config = Config(
    accessToken: appToken,
    // Android specific option
    // Optional: Enable or disable collection of event data.
    analyticsEventEnabled: true,
    // iOS specific option
    // Optional: Enable or disable automatic instrumentation of WebViews.
    webViewInstrumentation: true,
    // Optional: Enable or disable reporting successful HTTP requests to the MobileRequest event type.
    networkErrorRequestEnabled: true,
    // Optional: Enable or disable reporting network and HTTP request errors to the MobileRequestError event type.
    networkRequestEnabled: true,
    // Optional: Enable or disable crash reporting.
    crashReportingEnabled: true,
    // Optional: Enable or disable interaction tracing. Trace instrumentation still occurs, but no traces are harvested. This will disable default and custom interactions.
    interactionTracingEnabled: true,
    // Optional: Enable or disable capture of HTTP response bodies for HTTP error traces, and MobileRequestError events.
    httpResponseBodyCaptureEnabled: true,
    // Optional: Enable or disable agent logging.
    loggingEnabled: true,
    // Optional: Enable or disable print statements as Analytics Events.
    printStatementAsEventsEnabled: false,
    // Optional: Enable or disable automatic instrumentation of HTTP requests.
    httpInstrumentationEnabled: true,
  );

  // NewrelicMobile.instance.start(config, () {
  //   runApp(const MyApp());
  // });
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = NewrelicMobile.onError;
    await NewrelicMobile.instance.startAgent(config);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    var _ = FirebaseAnalytics.instance;

    runApp(const MyApp());
  }, (Object error, StackTrace stackTrace) {
    NewrelicMobile.instance.recordError(
      error,
      stackTrace,
      attributes: {"err_code": "launch_app"},
      isFatal: true,
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataModel()),
      ],
      builder: (context, child) {
        return _body(context);
      },
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
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
          navigatorObservers: [NewRelicNavigationObserver()],
          debugShowCheckedModeBanner: false,
          theme: scheme.getTheme(context, Brightness.light, dmodel),
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

class _IndexState extends State<Index> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    switch (dmodel.loadStatus) {
      case LoadStatus.init:
        return const CircularProgressIndicator();
      case LoadStatus.noUser:
        return const AccountInit();
      case LoadStatus.done:
        return const Home();
      case LoadStatus.expired:
        return const Placeholder();
    }
  }
}
