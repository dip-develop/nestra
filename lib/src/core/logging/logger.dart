import 'package:injectable/injectable.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart' as ext;

abstract class AppLogger {
  void debug(String message, [Object? error, StackTrace? stackTrace]);
  void info(String message, [Object? error, StackTrace? stackTrace]);
  void warn(String message, [Object? error, StackTrace? stackTrace]);
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

@LazySingleton(as: AppLogger)
class LoggerImpl extends AppLogger {
  LoggerImpl() : _logger = ext.Logger();
  final ext.Logger _logger;
  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.debug(message, error, stackTrace);
  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.info(message, error, stackTrace);
  @override
  void warn(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.warning(message, error, stackTrace);
  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.error(message, error, stackTrace);
}
