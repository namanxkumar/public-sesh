import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:testproj/pages/oninvitelink.dart';
import 'package:testproj/util/firestore.dart';
import 'package:testproj/util/locator.dart';
import 'package:testproj/util/models.dart';
import 'package:testproj/util/nav.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
import 'pages/sessions.dart';
import 'pages/profile.dart';
import 'pages/create.dart';
import 'package:provider/provider.dart';
import 'util/firestore.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var box;
  @override
  void initState() {
    initbox();
    super.initState();
    this.initDynamicLinks();
  }

  initbox() async {
    box = await Hive.openBox("auth");
  }

  var params;
  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        //TODO: IMPLEMENT JOIN GROUP
        print("LINKPATH:" + deepLink.queryParameters.toString());
        locator<NavigationService>().navigateTo(
          PageTransition(
            child: InviteLinkPage(params: deepLink.queryParameters),
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 0),
            reverseDuration: Duration(milliseconds: 0),
          ),
        );
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      //TODO: IMPLEMENT JOIN GROUP
      print("LINKPATH:" + deepLink.queryParameters.toString());
      locator<NavigationService>().navigateTo(
        PageTransition(
          child: InviteLinkPage(params: deepLink.queryParameters),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: 0),
          reverseDuration: Duration(milliseconds: 0),
        ),
      );
    }
  }

  var index = 0;
  void _onNavbarPress(int index) {
    print(index);

    setState(() {
      this.index = index;
    });
  }

  final _pages = [
    SessionsScreen(),
    // GroupsScreen(),
    ProfileScreen(),
    CreateScreen()
  ];

  // var onToday;
  // void onTodayPress() {
  //   setState(() {
  //     onToday = true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    print(params);
    box = Hive.box("auth");
    var firestoreService = FirestoreService();
    if (box.get('new') == false) {
      return MultiProvider(
        providers: [
          StreamProvider<UserModel>(
              create: (context) => firestoreService.getUser(),
              initialData: UserModel.fromFirestore(null)),
          StreamProvider<List<GroupModel>>(
              create: (context) => firestoreService.getGroups(),
              initialData: []),
          StreamProvider<List<SessionModel>>(
            create: (context) => firestoreService.listenToPostsRealTime(),
            updateShouldNotify: (_, __) => true,
            initialData: [SessionModel.fromFirestore(null, null)],
          ),
        ],
        child: WillPopScope(
          onWillPop: () async => false,
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              primary: true,
              backgroundColor: Theme.of(context).colorScheme.background,
              //appBar: CustomAppBar(),
              body: _pages[index],
              bottomNavigationBar: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.0),
                  topRight: Radius.circular(32.0),
                ),
                child: Theme(
                  data: ThemeData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: index,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Icon(
                            Icons.sports_esports,
                            color: Theme.of(context).colorScheme.onBackground,
                            size: 28,
                          ),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(top: 8.0, left: 12.0),
                          child: SizedBox(
                            width: 64,
                            height: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(33),
                              ),
                              child: Icon(
                                Icons.sports_esports,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        label: 'Home',
                      ),
                      // BottomNavigationBarItem(
                      //   icon: Padding(
                      //     padding: EdgeInsets.only(top: 8.0),
                      //     child: Icon(
                      //       Icons.grid_view,
                      //       color: Theme.of(context).colorScheme.onBackground,
                      //       size: 28,
                      //     ),
                      //   ),
                      //   activeIcon: Padding(
                      //     padding: EdgeInsets.only(top: 8.0),
                      //     child: SizedBox(
                      //       width: 64,
                      //       height: 40,
                      //       child: DecoratedBox(
                      //         decoration: BoxDecoration(
                      //           color: Theme.of(context).colorScheme.primary,
                      //           borderRadius: BorderRadius.circular(33),
                      //         ),
                      //         child: Icon(
                      //           Icons.grid_view,
                      //           color: Theme.of(context).colorScheme.onPrimary,
                      //           size: 28,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      //   label: 'Groups',
                      // ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Icon(
                            Icons.perm_identity,
                            color: Theme.of(context).colorScheme.onBackground,
                            size: 28,
                          ),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            width: 64,
                            height: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(33),
                              ),
                              child: Icon(
                                Icons.perm_identity,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        label: 'Profile',
                      ),
                      BottomNavigationBarItem(
                        activeIcon: Padding(
                          padding: EdgeInsets.only(top: 8.0, right: 12.0),
                          child: SizedBox(
                            width: 64,
                            height: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(33),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        icon: Padding(
                          padding: EdgeInsets.only(top: 8.0, right: 12.0),
                          child: SizedBox(
                            height: 40,
                            width: 64,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  width: 1.3,
                                ),
                                borderRadius: BorderRadius.circular(33),
                              ),
                              child: Icon(
                                Icons.add,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        label: 'Add',
                      ),
                    ],
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    onTap: _onNavbarPress,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
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
    return Loader();
  }
}
