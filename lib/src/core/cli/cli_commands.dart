import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';
import 'package:nestra/src/domain/usecases/apps_usecase.dart';

// CLI command model
sealed class CliCommand {}

final class CliRunHub extends CliCommand {}

final class CliRunApp extends CliCommand {
  CliRunApp(this.appId);
  final String appId;
}

final class CliRegister extends CliCommand {
  CliRegister({required this.url, required this.name, this.iconPath});
  final Uri url;
  final String name;
  final String? iconPath;
}

final class CliList extends CliCommand {}

final class CliClearCache extends CliCommand {
  CliClearCache(this.appId);
  final String appId;
}

final class CliReset extends CliCommand {}

final class CliInvalid extends CliCommand {
  CliInvalid(this.message);
  final String message;
}

({CliCommand command, ArgResults raw, ArgParser parser}) parseCliArgs(
  List<String> args,
) {
  final parser = ArgParser()
    ..addOption('app', help: 'Run a specific app by id')
    ..addFlag('list', help: 'List registered apps', negatable: false)
    ..addOption('register', help: 'Register app by URL (requires --name)')
    ..addOption('name', help: 'Name for app when using --register')
    ..addOption('icon', help: 'Icon path for --register')
    ..addOption('clear-cache', help: 'Clear cache for app id (stub)')
    ..addFlag('reset', help: 'Factory reset (stub)', negatable: false)
    ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false);
  try {
    final results = parser.parse(args);
    if (results['help'] == true) {
      stdout.writeln('Nestra command-line options:\n');
      stdout.writeln(parser.usage);
      exit(0);
    }
    if (results['list'] == true)
      return (command: CliList(), raw: results, parser: parser);
    if (results['reset'] == true)
      return (command: CliReset(), raw: results, parser: parser);
    final clear = results['clear-cache'] as String?;
    if (clear != null)
      return (command: CliClearCache(clear), raw: results, parser: parser);
    final regUrl = results['register'] as String?;
    if (regUrl != null) {
      final name = results['name'] as String?;
      if (name == null) {
        return (
          command: CliInvalid('Missing --name for --register'),
          raw: results,
          parser: parser,
        );
      }
      return (
        command: CliRegister(
          url: Uri.parse(regUrl),
          name: name,
          iconPath: results['icon'] as String?,
        ),
        raw: results,
        parser: parser,
      );
    }
    final appId = results['app'] as String?;
    if (appId != null)
      return (command: CliRunApp(appId), raw: results, parser: parser);
    return (command: CliRunHub(), raw: results, parser: parser);
  } catch (e) {
    return (
      command: CliInvalid(e.toString()),
      raw: parser.parse(<String>[]),
      parser: parser,
    );
  }
}

Future<void> executePreUiCommand(
  CliCommand cmd, {
  required AppsUseCase apps,
}) async {
  switch (cmd) {
    case CliList():
      final list = await apps.list();
      stdout.writeln(jsonEncode(list.map(_appToJson).toList()));
      exit(0);
    case CliRegister(:final url, :final name, :final iconPath):
      final created = await apps.create(
        name: name,
        url: url,
        iconPath: iconPath,
      );
      stdout.writeln(jsonEncode({'status': 'registered', 'id': created.id}));
      exit(0);
    case CliClearCache(:final appId):
      stdout.writeln(jsonEncode({'status': 'clear-cache-stub', 'id': appId}));
      exit(0);
    case CliReset():
      stdout.writeln(jsonEncode({'status': 'reset-stub'}));
      exit(0);
    case CliInvalid(:final message):
      stderr.writeln('Error: $message');
      exit(64); // EX_USAGE
    case CliRunApp():
    case CliRunHub():
      return; // Continue to UI
  }
}

Map<String, dynamic> _appToJson(AppDefinition a) => {
  'id': a.id,
  'name': a.name,
  'url': a.url.toString(),
  'createdAt': a.createdAt.toIso8601String(),
  'updatedAt': a.updatedAt.toIso8601String(),
};
