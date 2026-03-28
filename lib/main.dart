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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        ChangeNotifierProvider(create: (_) => HouseholdProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ChoreProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const ShareSquareApp(),
    ),
  );
}
