class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://localhost:3000/api/v1';

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
  static const String subscription = '/subscription';
  static const String subscriptionPlans = '/subscription/plans';

  // Profile
  static const String profile = '/profile';
}
