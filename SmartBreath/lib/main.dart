import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbreath/Anasayfa.dart';
import 'package:smartbreath/Onboarding_screen.dart';
import 'package:smartbreath/deneme2.dart';
import 'models_providers/theme_provider.dart';

bool rememberme = true;
bool show = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(['tr', 'en']);
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  rememberme = prefs.getBool('BeniHatirla') ?? false;
  show = prefs.getBool('ON_BOARDING') ?? true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return LocaleBuilder(
          builder: (locale) => MaterialApp(
            localizationsDelegates: Locales.delegates,
            supportedLocales: Locales.supportedLocales,
            locale: locale,
            title: "SmartBreath",
            themeMode: themeProvider.themeMode,
            theme: MyThemes.lightTheme,
            darkTheme: MyThemes.darkTheme,
            debugShowCheckedModeBanner: false,
            home: show
                ? OnboardingScreen()
                : rememberme
                    ? Example()
                    : Anasayfa(),
          ),
        );
      });
}
