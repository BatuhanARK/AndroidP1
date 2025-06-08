import 'package:flutter/material.dart';
import 'package:android_p1/home.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:android_p1/themes.dart';

/// Global notification plugin instance.
/// This allows sending local notifications anywhere in the app.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// The entry point of the Flutter application.
/// Initializes notification settings before running the app.
void main() async {
  // Ensures all Flutter bindings and plugins are initialized before app startup.
  WidgetsFlutterBinding.ensureInitialized();

  // Set up Android-specific notification settings.
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  // Initialize the notification plugin.
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Launch the app with the Home screen as the start page.
  runApp(ChangeNotifierProvider(
      create: (_) => ThemeNotifier(
        ThemeData(
          primaryColor: Colors.red,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, primary: Colors.red),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.red,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'Roboto',
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.red,
          ),
        ),
        'Roboto',
      ),
      child: const MyApp(),
    ),
  );
}

/// Unused example widget for demo purposes.
/// You can remove this class if not used anywhere.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.themeData.copyWith(
          textTheme: Theme.of(context).textTheme.apply(fontFamily: theme.fontFamily),
        ),
        home: const Home(),
      ),
    );
  }
}
