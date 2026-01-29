import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'app_error.dart';

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // static logger
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // rate limiting for duplicate errors
  final Map<String, DateTime> _lastLogTime = {};

  // Handle error and show to user
  void handle(BuildContext context, AppError error) {
    _logError(error); //error log

    // to show to user
    _showErrorToUser(context, error);
  }

  //  without showing to user
  void handleSilent(AppError error) {
    _logError(error);
  }

  // log error with rate limiting
  void _logError(AppError error) {
    final key = error.message;
    final now = DateTime.now();

    //errors max once per 2 seconds
    if (_lastLogTime[key] != null &&
        now.difference(_lastLogTime[key]!) < const Duration(seconds: 2)) {
      return;
    }

    _lastLogTime[key] = now;

    switch (error.severity) {
      case ErrorSeverity.info:
        _logger.i(error.message, error: error.originalError);
        break;
      case ErrorSeverity.warning:
        _logger.w(error.message, error: error.originalError);
        break;
      case ErrorSeverity.error:
        _logger.e(error.message, error: error.originalError);
        break;
      case ErrorSeverity.critical:
        _logger.f(error.message, error: error.originalError);
        break;
    }
  }

  // show error to user SnackBar/Dialog
  void _showErrorToUser(BuildContext context, AppError error) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    // for critical errors+dialog
    if (error.severity == ErrorSeverity.critical) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(error.title ?? 'Critical Error'),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      messenger.clearSnackBars();

      // for other errors
      messenger.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error.title != null)
                Text(
                  error.title!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              Text(error.message),
            ],
          ),
          backgroundColor: _getColorForSeverity(error.severity),
          duration: _getDurationForSeverity(error.severity),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () => messenger.hideCurrentSnackBar(),
          ),
        ),
      );
    }
  }

  /// getColor based on severity
  Color _getColorForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }

  /// getduration based on severity
  Duration _getDurationForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return const Duration(seconds: 2);
      case ErrorSeverity.warning:
        return const Duration(seconds: 4);
      case ErrorSeverity.error:
      case ErrorSeverity.critical:
        return const Duration(seconds: 6);
    }
  }

  /// success message
  void showSuccess(BuildContext context, String message, {String? title}) {
    if (!context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();

      messenger.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              Text(message),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  /// info message
  void showInfo(BuildContext context, String message, {String? title}) {
    if (!context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();

      messenger.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              Text(message),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}
