import 'package:logger/logger.dart';

void info(dynamic message) => Logger().i(message);
void debug(dynamic message) => Logger().d(message);
void waring(dynamic message) => Logger().w(message);
void error(dynamic message) => Logger().e(message);
