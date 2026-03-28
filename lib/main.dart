import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/firebase_options.dart';
import 'app.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/household_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/chore_provider.dart';
import 'providers/chat_provider.dart';

void main() {
  runZonedGuarded(_main, (error, stack) {
    debugPrint('=== UNCAUGHT ZONE ERROR ===\n$error\n$stack');
  });
}

Future<void> _main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    initError = 'dotenv: $e';
  }
  if (initError == null) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      initError = 'Firebase: $e';
    }
  }
  if (initError != null) {
    runApp(_ErrorApp(initError));
    return;
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, HouseholdProvider>(
          create: (_) => HouseholdProvider(),
          update: (_, auth, household) {
            household!.syncFromAuth(auth.currentUser?.householdId);
            return household;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, auth, expense) {
            expense!.syncFromAuth(auth.currentUser?.householdId);
            return expense;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChoreProvider>(
          create: (_) => ChoreProvider(),
          update: (_, auth, chore) {
            chore!.syncFromAuth(auth.currentUser?.householdId);
            return chore;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, auth, chat) {
            chat!.syncFromAuth(auth.currentUser?.householdId);
            return chat;
          },
        ),
      ],
      child: const ShareSquareApp(),
    ),
  );
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp(this.message);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'Startup error:\n\n$message',
              style: const TextStyle(fontSize: 14, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
