import 'package:flutter/material.dart';
import 'package:my_flutter_app/ui/screens/users/company/pages/Roadmaps/createroadmap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  CreateNewRoadmap(), // يروح على الهوم مباشرة
    );
  }
}