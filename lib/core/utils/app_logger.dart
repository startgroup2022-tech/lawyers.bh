import 'package:logger/logger.dart';

class AppLogger {
  static late Logger _logger;

  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  static void d(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.wtf(message, error: error, stackTrace: stackTrace);
  }
}

extension LogExtension on Object {
  void logDebug({StackTrace? stackTrace}) => AppLogger.d(toString(), stackTrace: stackTrace);
  void logInfo({StackTrace? stackTrace}) => AppLogger.i(toString(), stackTrace: stackTrace);
  void logWarning({StackTrace? stackTrace}) => AppLogger.w(toString(), stackTrace: stackTrace);
  void logError({StackTrace? stackTrace}) => AppLogger.e(toString(), stackTrace: stackTrace);
}