import 'application_config_interface.dart';

abstract interface class Application {
  Uri get baseUrl;
  ApplicationConfig get config;
}
