import 'package:smart_career_hub/ui/screens/onboarding/OnboardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_career_hub/ui/screens/auth/login/login_screen.dart';
import 'core/api/dio_helper.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  DioHelper.init();

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(MyApp(showOnboarding: !onboardingDone));

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Career Hub',
      debugShowCheckedModeBanner: false,
      home: showOnboarding ? const OnboardingScreen() : const LoginScreen(),
    );
  }
}