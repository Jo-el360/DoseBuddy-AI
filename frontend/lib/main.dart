import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const DoseBuddyApp(),
    ),
  );
}

class DoseBuddyApp extends StatelessWidget {
  const DoseBuddyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoseBuddy AI',
      debugShowCheckedModeBanner: false,
      theme: DoseBuddyTheme.elderlyTheme,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const DashboardScreen() : const AuthScreen();
        },
      ),
    );
  }
}
