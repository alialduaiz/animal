import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Loading.dart';
import 'User/UserHome.dart';
import 'main.dart';

class LanguageSelectionBottomBar extends StatefulWidget {
  @override
  _LanguageSelectionBottomBarState createState() =>
      _LanguageSelectionBottomBarState();
}

class _LanguageSelectionBottomBarState
    extends State<LanguageSelectionBottomBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text('English'),
                  onTap: () {
                    changeLocale('en');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('العربية'),
                  onTap: () {
                    changeLocale('ar');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
    else{
      // Get.offAll(MyApp());
      // Navigator.pushAndRemoveUntil(
      //     context,
      //     CupertinoPageRoute(
      //         builder: (_) =>MyHome()),
      //         (route) => false);
    }
  }

  void changeLocale(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);

    // Update the app's locale and rebuild the UI
    Locale newLocale = Locale(languageCode);
    MyApp.setLocale(context, newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(

          icon: Icon(Icons.home),
          label: '   ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.language),
          label: '  ',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Color(0xFF087474),
      onTap: _onItemTapped,
    );
  }
}

class MyApp1 extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyApp1State state = context.findAncestorStateOfType<_MyApp1State>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyApp1State createState() => _MyApp1State();
}

class _MyApp1State extends State<MyApp1> {
  Locale _locale = const Locale('en');

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        // Your app theme
      ),
      locale: _locale,
      supportedLocales: [
        const Locale('en'),
        const Locale('ar'),
      ],
      localizationsDelegates: [
        // Your app's localization delegates
      ],
      // Your app's initial route and routes configuration
    );
  }
}
