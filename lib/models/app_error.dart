import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_dialog.dart';

/// Typed error produced by [ApiProvider] from every failed HTTP call.
///
/// Replaces the scattered `err.response?.data is Map ? ...` pattern in screens.
/// Switch on [code] for business-logic errors; check [isServerFault] /
/// [isNetworkError] for infrastructure errors.
class AppError implements Exception {
  final String code;
  final String message;
  final int statusCode; // 0 = no response (network / timeout)

  const AppError({
    required this.code,
    required this.message,
    required this.statusCode,
  });

  // ── Convenience constructors ──────────────────────────────────────────────

  factory AppError.fromDio(DioException e) {
    // Network-level failure — no HTTP response at all.
    if (e.response == null) {
      return const AppError(
        code: 'NETWORK_ERROR',
        message: 'Check your internet connection and try again.',
        statusCode: 0,
      );
    }

    final data = e.response!.data;
    final message =
        (data is Map ? data['message'] as String? : data?.toString()) ??
            'Server error';
    final code =
        (data is Map ? data['code'] as String? : null) ?? 'UNKNOWN';

    return AppError(
      code: code,
      message: message,
      statusCode: e.response!.statusCode ?? 0,
    );
  }

  // ── Predicates ────────────────────────────────────────────────────────────

  bool get isNetworkError => statusCode == 0;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isServerFault => statusCode >= 500;

  // ── UI ───────────────────────────────────────────────────────────────────

  /// Show a [CustomDialog] for this error.
  ///
  /// [title] defaults to 'Server Error' for 5xx faults, 'Error' otherwise.
  /// [callback] runs when the user dismisses the dialog.
  void show(
    BuildContext context, {
    String? title,
    VoidCallback? callback,
  }) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: title ?? (isServerFault ? 'Server Error' : 'Error'),
        description: message,
        buttonText: 'Okay',
        images: [],
        callback: callback ?? () {},
      ),
    );
  }

  @override
  String toString() => 'AppError($statusCode $code): $message';
}
