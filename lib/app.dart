import 'package:flutter/material.dart';
import 'package:pardarsh_application/provider/auth_provider.dart';
import 'package:pardarsh_application/provider/project_provider.dart';
import 'package:pardarsh_application/provider/report_provider.dart';
import 'package:pardarsh_application/provider/contractor_provider.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => ContractorProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appName,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
      ),
    );
  }
}
