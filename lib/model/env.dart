// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

// API Config
var HOST = dotenv.env['HOST'] ?? "";
var GO_HOST = dotenv.env['GO_HOST'] ?? "";
var GO_API_KEY = dotenv.env['GO_API_KEY'] ?? "";
var API_KEY = dotenv.env['API_KEY'] ?? "";

// AWS Config
var AWS_ACCESS_KEY = dotenv.env['AWS_ACCESS_KEY'] ?? "";
var AWS_SECRET_ACCESS_KEY = dotenv.env['AWS_SECRET_ACCESS_KEY'] ?? "";
var AWS_S3_BUCKET = dotenv.env['AWS_S3_BUCKET'] ?? "";

// OTEL Config
var OTEL_BACKEND_HOST = dotenv.env['OTEL_BACKEND_HOST'] ?? "";
var OTEL_BACKEND_API_KEY = dotenv.env['OTEL_BACKEND_API_KEY'] ?? "";
var OTEL_INSTRUMENTATION_NAME =
    kDebugMode ? "workout-notepad-app-dev" : "workout-notepad-app-prod";
var OTEL_SESSION_ID = Uuid().v4();

// RevenueCat
var RC_APPL_API_KEY = dotenv.env['RC_APPL_API_KEY'] ?? "";
var RC_GOOG_API_KEY = dotenv.env['RC_GOOG_API_KEY'] ?? "";
var RC_ENTITLEMENT_ID = dotenv.env['RC_ENTITLEMENT_ID'] ?? "";

// Misc
const KG_TO_LBS_CONVERSTION = 2.20462;
