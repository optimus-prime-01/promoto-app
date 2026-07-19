/// Application configuration constants.
/// In production, these should be injected via build flavors or
/// runtime configuration rather than hardcoded.
class AppConfig {
  AppConfig._();

  // Razorpay
  // TODO: Move to dart-define or .env for production builds
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_TFGwQAfNMSxrNC',
  );

  // App name
  static const String appName = 'Promoto';
}
