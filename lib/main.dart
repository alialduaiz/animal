import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';
import 'globals.dart';
import 'language.dart';
import 'Loading.dart';  // Import this file to use global variables
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('ar');
  bool _navigateToLoading = false;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
      _navigateToLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_navigateToLoading) {
      _navigateToLoading = false;
      return loading(locale: _locale);  // Ensure that 'loading' widget is defined and correctly implemented
    }
    localee = _locale;
    return MaterialApp(
      navigatorObservers: [routeObserver],
      title: 'My App',
      locale: _locale,
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ar', ''),
      ],
      home:
      LanguageSelectionPage(setLocale),
    );
  }
}

class LanguageSelectionPage extends StatelessWidget {
  final Function(Locale) setLocale;

  LanguageSelectionPage(this.setLocale);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose language'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text('English'),
              onTap: () {
                changeLocale(context, 'en');
              },
            ),
            ListTile(
              title: Text('العربية'),
              onTap: () {
                changeLocale(context, 'ar');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: LanguageSelectionBottomBar(),

    );
  }

  void changeLocale(BuildContext context, String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    setLocale(Locale(languageCode));
  }
}