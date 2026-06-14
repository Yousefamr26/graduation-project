import 'package:flutter/material.dart';

class DashboardCardModel {
  final IconData icon;
  final String title;
  final String count;
  final String subtitle;

  DashboardCardModel({
    required this.icon,
    required this.title,
    required this.count,
    required this.subtitle,
  });
}