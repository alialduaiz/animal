import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:ui' as UI;
import 'package:untitled6/User/Login.dart';
import 'dart:async';

import 'language.dart';

class loading extends StatelessWidget {
  final Locale? locale;


  loading({this.locale});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            basePath: 'assets/lang',
            useCountryCode: false,
            forcedLocale: locale,
          ),
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ar', ''),
      ],
      locale: locale,
      builder: (context, child) {
        String languageCode = Localizations.localeOf(context).languageCode;
        final isRtl = languageCode == 'ar';
        return Directionality(
          textDirection: isRtl ? UI.TextDirection.rtl : UI.TextDirection.ltr,
          child: child ?? Container(),
        );
      },
      title: 'Animal Reporting',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MySplashScreen(),
    );
  }
}


class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller and animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    Timer(Duration(seconds: 4), () => _controller.stop());
    Timer(
      Duration(seconds: 7),
          () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF087474),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: RotationTransition(
                  turns: _animation,
                  child: Image(
                    image: AssetImage('assets/img/animals.jpg'),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40), // add some spacing between the image and CircularProgressIndicator
            Text(
              FlutterI18n.translate(context, 'welcome'), // Translated text
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Color(0xFF087474),
                fontSize: 30,
                shadows: [
                  Shadow(
                    color: Colors.yellow.withOpacity(0.7),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 2 * 3.14,
                  child: child,
                );
              },
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),

    );
  }
}
