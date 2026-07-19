class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://academic-planner-backend-vfbf.onrender.com/api/v1',
  );

  const AppConfig._();
}
