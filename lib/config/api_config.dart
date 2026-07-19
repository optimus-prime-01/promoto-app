class ApiConfig {
  ApiConfig._();

  // TODO(security): Use dart-define for base URL per environment.
  // Production builds must use HTTPS.
  // Example: flutter build --dart-define=API_BASE_URL=https://api.promoto.in/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  // Razorpay - injected via dart-define for production builds.
  // Example: flutter build --dart-define=RAZORPAY_KEY_ID=rzp_live_xxxxx
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_TFGwQAfNMSxrNC',
  );

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Business
  static const String businesses = '/businesses';
  static const String businessById = '/businesses/{id}';

  // Audit
  static const String audits = '/audits';
  static const String auditRun = '/audits/run';
  static const String auditById = '/audits/{id}';

  // Reviews
  static const String reviews = '/reviews';
  static const String reviewReply = '/reviews/{id}/reply';
  static const String reviewAiReply = '/reviews/{id}/ai-reply';

  // Posts
  static const String posts = '/posts';
  static const String postGenerate = '/posts/generate';
  static const String postById = '/posts/{id}';

  // Customers
  static const String customers = '/customers';
  static const String customerById = '/customers/{id}';

  // Subscription
  static const String subscription = '/subscriptions';
  static const String subscriptionCurrent = '/subscriptions/current';
  static const String subscriptionPlans = '/subscriptions/plans';

  // Profile
  static const String profile = '/profile';
}
