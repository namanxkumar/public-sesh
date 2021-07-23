import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:testproj/homepage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _firestore = FirebaseFirestore.instance;
  var box = Hive.box("auth");
  @override
  void initState() {
    getprefs();
    initDynamicLinks();
    super.initState();
  }

  var emailAuth;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> getprefs() async {
    final SharedPreferences prefs = await _prefs;
    try {
      emailAuth = prefs.getString('email');
    } catch (e) {
      print(e);
    }
  }

  Future<void> setprefs(email) async {
    final SharedPreferences prefs = await _prefs;
    try {
      prefs.setString("email", email);
    } catch (e) {
      print(e);
    }
  }

  var acs = ActionCodeSettings(
      // URL you want to redirect back to. The domain (www.example.com) for this
      // URL must be whitelisted in the Firebase Console.
      url: 'https://sesher.page.link',
      // This must be true
      handleCodeInApp: true,
      androidPackageName: 'com.example.sesh',
      // installIfNotAvailable
      androidInstallApp: true,
      // minimumVersion
      androidMinimumVersion: '12');

  final _emailController = TextEditingController();

  int _validate = 0;
  onSubmit() async {
    emailAuth = _emailController.text.trim();
    if (EmailValidator.validate(emailAuth)) {
      setState(() {
        _validate = 2;
        FocusScope.of(context).unfocus();
      });
      Navigator.push(
        context,
        PageTransition(
          child: Loader(),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 200),
        ),
      );
      setprefs(emailAuth);
      await FirebaseAuth.instance
          .sendSignInLinkToEmail(email: emailAuth, actionCodeSettings: acs)
          .catchError(
              (onError) => print('Error sending email verification $onError'))
          .then((value) => print('Successfully sent email verification'));
      Navigator.push(
        context,
        PageTransition(
          child: DynamicLinkSection(
            emailAuth: emailAuth,
          ),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 200),
        ),
      );
    } else {
      setState(() {
        _validate = 1;
      });
    }
  }

  var auth = FirebaseAuth.instance;

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;
      if (deepLink != null) {
        Navigator.push(
          context,
          PageTransition(
            child: Loader(),
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 200),
            reverseDuration: Duration(milliseconds: 200),
          ),
        );
        signin(deepLink.toString());
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      Navigator.push(
        context,
        PageTransition(
          child: Loader(),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 200),
        ),
      );
      signin(deepLink.toString());
    }
  }

  Future<void> signin(emailLink) async {
    if (auth.isSignInWithEmailLink(emailLink)) {
      // The client SDK will parse the code from the link for you.
      auth
          .signInWithEmailLink(email: emailAuth, emailLink: emailLink)
          .then((value) {
        // You can access the new user via value.user
        // Additional user info profile *not* available via:
        // value.additionalUserInfo.profile == null
        // You can check if the user is new or existing:
        // value.additionalUserInfo.isNewUser;
        // var userEmail = value.user;
        print(
            'Successfully signed in with email link! Checking signup state...');
        _firestore
            .collection("users")
            .doc(auth.currentUser?.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) async {
          if (documentSnapshot.exists) {
            await box.put('new', false);
            Navigator.push(
              context,
              PageTransition(
                child: MyHomePage(),
                type: PageTransitionType.rightToLeft,
                duration: Duration(milliseconds: 200),
                reverseDuration: Duration(milliseconds: 200),
              ),
            );
          } else {
            await box.put('new', true);
            // TODO ADD INVITE ONLY CHECK HERE
            print("First time user, redirecting to signup page");
            Navigator.push(
              context,
              PageTransition(
                child: SignupSection(),
                type: PageTransitionType.rightToLeft,
                duration: Duration(milliseconds: 200),
                reverseDuration: Duration(milliseconds: 200),
              ),
            );
          }
        });
      }).catchError((onError) {
        print('Error signing in with email link $onError');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: EmailSection(
        controller: _emailController,
        onSubmit: onSubmit,
        validate: _validate,
      ),
    );
  }
}

class SignupSection extends StatefulWidget {
  @override
  _SignupSectionState createState() => _SignupSectionState();
}

class _SignupSectionState extends State<SignupSection> {
  final _formKey = GlobalKey<FormState>();

  final _firestore = FirebaseFirestore.instance;

  final auth = FirebaseAuth.instance;
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController usernameEditingController = TextEditingController();

  var _loading = false;

  Future<bool> validateUsername(value) async {
    var temp = false;
    try {
      await _firestore
          .collection("usernames")
          .doc(value)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        print(documentSnapshot.exists);
        if (documentSnapshot.exists == false) {
          temp = true;
        }
      });
    } catch (e) {
      print(e);
    }
    print(temp);
    return temp;
  }

  var _usernameError = 0;
  Future<void> updateParams(name, username) async {
    var box = await Hive.openBox("auth");
    if ((await validateUsername(username)) == true) {
      try {
        await _firestore
            .collection("usernames")
            .doc(username)
            .set({'uid': auth.currentUser!.uid}).then((value) async {
          await _firestore.collection("users").doc(auth.currentUser!.uid).set({
            'uid': auth.currentUser!.uid,
            'name': name.toString(),
            'username': username.toString(),
            'email': auth.currentUser!.email,
            'foreigntags': {"discord": "", "steam": "", "epic": ""},
            'numconn': 0,
            'groups': [],
            'recents': [],
          }).then((value) async {
            await box.put('new', false);
            auth.currentUser!.updateDisplayName(name.toString());
          });
        });
        _usernameError = 2;
      } on Exception catch (e) {
        // TODO
        print(e);
      }
    } else if (username.length == 0) {
      _usernameError = 0;
    } else {
      _usernameError = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 28.0, right: 28.0),
              child: _usernameError == 2
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          "Almost done, choose a display name and username to finish.",
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: nameEditingController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter a display name';
                                  } else if (value.length >= 26) {
                                    return 'Display name cannot be longer than 26 characters';
                                  }
                                  return null;
                                },
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.0,
                                ),
                                decoration: InputDecoration(
                                  fillColor: Color(0xff181818),
                                  hintText: 'Display Name',
                                  hintStyle: GoogleFonts.poppins(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  border: InputBorder.none,
                                ),
                                cursorColor:
                                    Theme.of(context).colorScheme.primary,
                                textInputAction: TextInputAction.next,
                                autofocus: true,
                                keyboardType: TextInputType.name,
                              ),
                              TextFormField(
                                controller: usernameEditingController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Choose a username';
                                  } else if (value.length >= 30) {
                                    return 'Username cannot be longer than 30 characters';
                                  } else if (!RegExp(r"^[a-zA-Z0-9._]+$")
                                      .hasMatch(value)) {
                                    return "Username cannot end with a period, and can only contain letters, numbers, periods or underscores.";
                                  }
                                  return null;
                                },
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.0,
                                ),
                                decoration: InputDecoration(
                                  fillColor: Color(0xff181818),
                                  hintText: 'Username',
                                  hintStyle: GoogleFonts.poppins(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  border: InputBorder.none,
                                ),
                                cursorColor:
                                    Theme.of(context).colorScheme.primary,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.name,
                              ),
                              Text(
                                _usernameError == 0
                                    ? ""
                                    : (_usernameError == 1
                                        ? "Username already exists"
                                        : "You're in! Loading..."),
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _usernameError == 2
                                    ? () {}
                                    : () async {
                                        setState(() {
                                          _loading = true;
                                          _usernameError = 0;
                                        });
                                        await Future.delayed(
                                            Duration(milliseconds: 500));
                                        if (_formKey.currentState!.validate()) {
                                          await updateParams(
                                              nameEditingController.text.trim(),
                                              usernameEditingController.text
                                                  .trim());
                                        }
                                        setState(() {
                                          if (_usernameError == 2) {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                child: MyHomePage(),
                                                type: PageTransitionType
                                                    .rightToLeft,
                                                duration:
                                                    Duration(milliseconds: 200),
                                                reverseDuration:
                                                    Duration(milliseconds: 200),
                                              ),
                                            );
                                          }

                                          _loading = false;
                                        });
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 8.0,
                                      left: 16.0,
                                      right: 16.0),
                                  primary: Theme.of(context)
                                      .colorScheme
                                      .primaryVariant,
                                  onPrimary:
                                      Theme.of(context).colorScheme.primary,
                                  textStyle: GoogleFonts.poppins(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                  ),
                                ),
                                child: _loading
                                    ? Text("Loading...")
                                    : Text("Submit"),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          )),
    );
  }
}

class EmailSection extends StatelessWidget {
  const EmailSection(
      {Key? key, this.controller, required this.onSubmit, this.validate})
      : super(key: key);
  final controller;
  final Function onSubmit;
  final validate;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 28.0, right: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Hi.",
                  style: GoogleFonts.poppins(
                      fontSize: 72,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(
                  height: 15,
                ),
                Email(
                    controller: controller,
                    pressed: onSubmit,
                    validate: validate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DynamicLinkSection extends StatefulWidget {
  const DynamicLinkSection({Key? key, this.emailAuth}) : super(key: key);
  final emailAuth;

  @override
  _DynamicLinkSectionState createState() => _DynamicLinkSectionState();
}

class _DynamicLinkSectionState extends State<DynamicLinkSection> {
  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.of(context).pushReplacement(PageTransition(
          child: WaitPage(),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: 100),
        ));
      }
    });
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 28.0, right: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "We've sent you a link",
                  style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Make sure to check your spam folder, just in case, we'll wait.",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: LoginPage(),
                        type: PageTransitionType.rightToLeft,
                        duration: Duration(milliseconds: 200),
                        reverseDuration: Duration(milliseconds: 200),
                      ),
                    );
                  },
                  child: Text(
                    "Use a different email",
                    style: GoogleFonts.poppins(
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WaitPage extends StatelessWidget {
  const WaitPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 28.0, right: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Looks like you've logged in - you can close this screen and enjoy Sesh!",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
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

class Email extends StatelessWidget {
  const Email(
      {Key? key,
      required this.controller,
      required this.pressed,
      required this.validate})
      : super(key: key);

  final TextEditingController controller;
  final Function pressed;
  final int validate;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter your email to get started",
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                  ),
                  decoration: InputDecoration(
                    fillColor: Color(0xff181818),
                    hintText: 'Email',
                    hintStyle: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                    ),
                    errorText: validate == 1
                        ? "Please enter a valid email address"
                        : null,
                    border: InputBorder.none,
                  ),
                  cursorColor: Theme.of(context).colorScheme.primary,
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  controller: controller,
                ),
              ),
            ),
            CheckButton(pressed)
          ],
        ),
      ],
    );
  }
}

class CheckButton extends StatelessWidget {
  // final onTodayPress;
  // GreenButton(this.onTodayPress);
  CheckButton(this.pressed);
  final pressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47.0,
      width: 47.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Theme.of(context).colorScheme.primaryVariant,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            // customBorder: ,
            child: Icon(
              Icons.arrow_forward,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            // splashColor: Color(0xff000000),
            onTap: pressed,
          ),
        ),
      ),
    );
  }
}
