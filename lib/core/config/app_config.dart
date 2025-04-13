import '/core/config/environment.dart';

class AppConfig {
  final String apiKey;
  final Environment environment;

  AppConfig({required this.apiKey, required this.environment});

  factory AppConfig.development() {
    return AppConfig(
      apiKey: '8d887598986e91cded96a27dd98e647c',
      environment: Environment.development,
    );
  }

  factory AppConfig.production() {
    return AppConfig(
      apiKey:
          '8d887598986e91cded96a27dd98e647c', // In a real app, would be different from dev
      environment: Environment.production,
    );
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isProduction => environment == Environment.production;
}
