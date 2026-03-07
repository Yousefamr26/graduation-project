import 'package:flutter/material.dart';

class AnalyticsModel {
  final String category;
  final List<MetricModel> metrics;
  final Map<String, int> lineChartData;
  final Map<String, double> pieChartData;
  final String pieChartTitle;
  final String lineChartTitle;
  final Map<String, int>? barChartData; // Optional for some categories
  final String? barChartTitle;

  AnalyticsModel({
    required this.category,
    required this.metrics,
    required this.lineChartData,
    required this.pieChartData,
    required this.pieChartTitle,
    required this.lineChartTitle,
    this.barChartData,
    this.barChartTitle,
  });
}

class MetricModel {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  MetricModel({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}