import '../interfaces/application_config_interface.dart';
import '../interfaces/application_interface.dart';

final class Copilot implements Application {
  @override
  Uri get baseUrl => Uri.parse("https://copilot.microsoft.com/");

  @override
  ApplicationConfig get config => _CopilotConfig();
}

final class _CopilotConfig implements ApplicationConfig {}
