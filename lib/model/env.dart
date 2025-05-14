// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// API Config
const HOST = String.fromEnvironment("HOST", defaultValue: "");
const GO_HOST = String.fromEnvironment("GO_HOST", defaultValue: "");
const GO_API_KEY = String.fromEnvironment("GO_API_KEY", defaultValue: "");
const API_KEY = String.fromEnvironment("API_KEY", defaultValue: "");

// AWS Config
const AWS_ACCESS_KEY =
    String.fromEnvironment("AWS_ACCESS_KEY", defaultValue: "");
const AWS_SECRET_ACCESS_KEY =
    String.fromEnvironment("AWS_SECRET_ACCESS_KEY", defaultValue: "");
const AWS_S3_BUCKET = String.fromEnvironment("AWS_S3_BUCKET", defaultValue: "");

// OTEL Config
const OTEL_BACKEND_HOST =
    String.fromEnvironment("OTEL_BACKEND_HOST", defaultValue: "");
const OTEL_BACKEND_API_KEY =
    String.fromEnvironment("OTEL_BACKEND_API_KEY", defaultValue: "");
var OTEL_INSTRUMENTATION_NAME =
    kDebugMode ? "workout-notepad-app-dev" : "workout-notepad-app-prod";
var OTEL_SESSION_ID = Uuid().v4();

// RevenueCat
const RC_APPL_API_KEY =
    String.fromEnvironment("RC_APPL_API_KEY", defaultValue: "");
const RC_GOOG_API_KEY =
    String.fromEnvironment("RC_GOOG_API_KEY", defaultValue: "");
const RC_ENTITLEMENT_ID =
    String.fromEnvironment("RC_ENTITLEMENT_ID", defaultValue: "");

// Misc
const KG_TO_LBS_CONVERSTION = 2.20462;
