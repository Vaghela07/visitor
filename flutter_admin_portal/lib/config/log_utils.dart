import 'dart:developer' as dev;

class LogUtils {
  LogUtils._();

  static void info(String message, {String tag = 'APP_INFO'}) {
    dev.log('[$tag] $message');
  }

  static void warning(String message, {String tag = 'APP_WARN'}) {
    dev.log('[$tag] ⚠️ $message');
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace, String tag = 'APP_ERROR'}) {
    dev.log('[$tag] ❌ $message', error: error, stackTrace: stackTrace);
  }
}
