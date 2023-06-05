import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

String currentLanguage = 'AR';
final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? '';
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  MyAppBar({Key? key}) : preferredSize = Size.fromHeight(kToolbarHeight), super(key: key);

  @override
  final Size preferredSize;

  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  void initState() {
    super.initState();
    loadLanguagePreference().then((language) {
      setState(() {
        currentLanguage = language;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.translate('title')),
      actions: [
        PopupMenuButton<String>(
          onSelected: (String result) {
            setState(() {
              currentLanguage = result;
              saveLanguagePreference(result);
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'EN',
              child: Text('English'),
            ),
            const PopupMenuItem<String>(
              value: 'AR',
              child: Text('عربى'),
            ),
          ],
        ),
      ],
    );
  }

  Future<String> loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('language');
    return language ?? 'AR'; // Return 'AR' as default if no language is saved
  }

  Future<void> saveLanguagePreference(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    appKey.currentState!.setLocale(Locale(language));
  }
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('ar');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: appKey,
      title: 'My App',
      locale: _locale,
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ar', ''),
      ],
      home: Scaffold(
        appBar: MyAppBar(),
        // other properties of your app...
      ),
    );
  }
}
