import 'package:proj_inz/core/errors/app_error_type.dart';

AppErrorType mapErrorToType(Object error) {
  final msg = error.toString().toLowerCase();

  if (msg.contains('connection') ||
      msg.contains('socket') ||
      msg.contains('clientexception')) {
    return AppErrorType.noConnection;
  }

  if (msg.contains('timeout')) {
    return AppErrorType.timeout;
  }

  if (msg.contains('404')) {
    return AppErrorType.notFound;
  }

  if (msg.contains('500')) {
    return AppErrorType.serverError;
  }

  return AppErrorType.unknown;
}