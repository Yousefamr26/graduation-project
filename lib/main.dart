import 'package:SmartCareerHub/ui/screens/auth/custom_splash_screen.dart';
import 'package:SmartCareerHub/ui/screens/auth/login/login_screen.dart';
import 'package:SmartCareerHub/ui/screens/users/company/pages/Applications/Applications.dart';
import 'package:SmartCareerHub/ui/screens/users/company/pages/Roadmaps/Create_editRoadmap.dart';
import 'package:SmartCareerHub/ui/screens/users/company/pages/com-dashboard.dart';
import 'package:flutter/material.dart';
import 'core/api/dio_helper.dart';


void main() {
  DioHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Career Hub',
debugShowCheckedModeBanner: false,
      home: LoginScreen()
    );
  }
}
