import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

Color statusColor(String status, AppColors colors) {
  return switch (status.toLowerCase()) {
    'alive' => colors.success,
    'dead' => colors.error,
    _ => colors.warning,
  };
}
