enum AppEnvironment {
  development,
  production,
}

class AppConfig {
  static const AppEnvironment environment = AppEnvironment.production;

  static bool get isDevelopment => environment == AppEnvironment.development;
  static bool get isProduction => environment == AppEnvironment.production;

  static bool get useMockServices => isDevelopment;
}