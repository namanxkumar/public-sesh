import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproj/pages/oninvitelink.dart';
import 'package:testproj/util/locator.dart';
import 'package:testproj/util/nav.dart';
import 'homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'package:get_it/get_it.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xff181818),
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("auth");
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sesh',
      navigatorKey: locator<NavigationService>().navigatorKey,
      theme: ThemeData(
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Color(0xffE85C5C),
          ),
        ),
        accentColor: Color(0xffE85C5C),
        colorScheme: ColorScheme(
          background: Color(0xff121212), //darkest [in use]
          surface: Color(0xff181818), //card(lighter) [in use]
          primary: Color(0xffE85C5C), //redbright [in use]
          primaryVariant:
              Color.fromRGBO(232, 92, 92, 0.1), //red translucent [in use]
          secondary: Color(0xffE9CE2C), //yellow accent [in use]
          secondaryVariant:
              Color.fromRGBO(77, 197, 145, 0.1), //green translucent [in use]
          brightness: Brightness.dark,
          error: Color(0xff650404), //dark red
          onBackground: Color(0xffFFFFFF), //heading text [in use]
          onError: Color(0xffFFFFFF), //tbd
          onPrimary: Color(0xff4B1F12), //DARK RED [in use]
          onSecondary: Color(0xffFFFFFF), //tbd
          onSurface: Color(0xffB3B3B3), //secondary text [in use]
        ),
        textTheme: TextTheme(
          button: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary, //redbright
          ),
          headline1: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 24.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return MajorError();
          if (snapshot.connectionState == ConnectionState.done) {
            // Assign listener after the SDK is initialized successfully
            FirebaseAuth.instance.authStateChanges().listen((User? user) {
              if (user == null) {
                Navigator.of(context).pushReplacement(PageTransition(
                  child: LoginPage(),
                  type: PageTransitionType.rightToLeft,
                  duration: Duration(milliseconds: 100),
                ));
              } else {
                Navigator.of(context).pushReplacement(PageTransition(
                  child: MyHomePage(),
                  type: PageTransitionType.rightToLeft,
                  duration: Duration(milliseconds: 100),
                ));
              }
            });
          }
          return Loader();
        },
      ),
    );
  }
}

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          )),
    );
  }
}

class MajorError extends StatelessWidget {
  const MajorError({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Center(
        child: Text("An error occurred, please reinstall"),
      )),
    );
  }
}
