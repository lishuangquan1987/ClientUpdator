import 'package:logd/logd.dart';

class LogHelper {
  static final _logger = Logger.get("logger");
  static void configureLogging() {
    Logger.configure(
      "logger",
      handlers: [
        Handler(
          formatter: JsonFormatter(),
          sink: FileSink("./Logs/log.log"),
          filters: [LevelFilter(LogLevel.trace)],
        ),
      ],
    );
  }

  static void debug(Object? msg) {
    _logger.debug(msg);
  }

  static void errorWithError(Object? err) {
    _logger.error("", error: err);
  }

  static void errorWithMsg(Object? msg) {
    _logger.error(msg);
  }

  static void trace(Object? msg) {
    _logger.trace(msg);
  }
}
