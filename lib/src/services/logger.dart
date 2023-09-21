import 'dart:developer' as dev;

import 'package:get_it/get_it.dart';

import 'service.dart';

class LoggerService {
  late ConfigService _configService;

  LoggerService() {
    _configService = GetIt.I.get<ConfigService>();
  }

  void error(String value) {
    if (_configService.loggerEnabled == true) {
      dev.log(value, name: 'ERROR');
    }
  }

  void log(String value) {
    if (_configService.loggerEnabled == true) {
      dev.log(value, name: 'LOG');
    }
  }

  void warn(String value) {
    if (_configService.loggerEnabled == true) {
      dev.log(value, name: 'WARN');
    }
  }
}
