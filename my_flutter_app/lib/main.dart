import 'package:flutter/material.dart';
import 'package:my_flutter_app/ui/screens/users/company/pages/Event/addnewevent.dart';
import 'package:my_flutter_app/ui/screens/users/company/pages/Event/eventscreen.dart';

import 'package:my_flutter_app/ui/screens/users/company/pages/Roadmaps/roadmapscreen.dart';
import 'package:my_flutter_app/ui/screens/users/company/pages/workshops/editworkshop.dart';
import 'package:my_flutter_app/ui/screens/users/company/pages/workshops/workshopsScreen.dart';
import 'package:my_flutter_app/ui/screens/users/company/pages/profile/profileCompany.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CompanyProfileScreen(), //
    );
  }
}