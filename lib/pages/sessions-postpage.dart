import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:testproj/pages/viewprofile.dart';
import 'package:testproj/util/firestore.dart';
import 'package:testproj/util/models.dart';

class SessionDetailPage extends StatefulWidget {
  SessionDetailPage(
      {Key? key,
      required this.data,
      required this.groupdets,
      required this.userdets})
      : super(key: key);
  final SessionModel data;
  final UserModel userdets;
  final List groupdets;
  static final _auth = FirebaseAuth.instance;

  @override
  _SessionDetailPageState createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  final _db = FirebaseFirestore.instance;
  var button;
  initState() {
    button = widget.data.creator == SessionDetailPage._auth.currentUser?.uid
        ? 2
        : (widget.data.users.contains(SessionDetailPage._auth.currentUser?.uid)
            ? 1
            : 0);
    super.initState();
  }

  onTap() {
    setState(() {
      if (button == 1) {
        button = 0;
        widget.data.users.remove(FirebaseAuth.instance.currentUser!.uid);
      } else if (button == 0) {
        button = 1;
        widget.data.users.add(FirebaseAuth.instance.currentUser!.uid);
      }
    });
  }

  Future<List<UserModel>> getAttendees(people) async {
    return people.length <= 10
        ? await _db
            .collection('users')
            .where('uid', whereIn: people)
            .get()
            .then((value) {
            return value.docs
                .map((e) => UserModel.fromFirestore(e.data()))
                .toList();
          })
        : await _db
                .collection('users')
                .where('uid', whereIn: people.sublist(0, 10))
                .get()
                .then((value) {
              return value.docs
                  .map((e) => UserModel.fromFirestore(e.data()))
                  .toList();
            }) +
            await _db
                .collection('users')
                .where('uid', whereIn: people.sublist(10, 20))
                .get()
                .then((value) {
              return value.docs
                  .map((e) => UserModel.fromFirestore(e.data()))
                  .toList();
            });
  }

  @override
  Widget build(BuildContext context) {
    final people = getAttendees(widget.data.users);
    var creator = widget.data.creator;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.only(left: 28, right: 28),
        child: Column(
          children: [
            CustomAppBar(
                button,
                widget.data.sid,
                onTap,
                widget.userdets.username,
                widget.data.users.length == widget.data.max ? true : false),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.data.game,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: FutureBuilder(
                            future: people,
                            builder: (context,
                                    AsyncSnapshot<List<UserModel>> snapshot) =>
                                Text(
                              snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData &&
                                      snapshot.data!.length != 0
                                  ? snapshot.data!
                                      .where((id) => id.uid == creator)
                                      .toList()[0]
                                      .username
                                  : "username",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: FancyStartEnd(
                            start: widget.data.start.hour.toString() +
                                ":" +
                                widget.data.start.minute.toString(),
                            end: widget.data.end.hour.toString() +
                                ":" +
                                widget.data.end.minute.toString(),
                            duration: (widget.data.duration.inMinutes ~/ 60)
                                    .toString() +
                                ":" +
                                (widget.data.duration.inMinutes % 60)
                                    .toString(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Attendees(people: people),
                        ),
                        Limit(
                            num: widget.data.users.length,
                            limit: widget.data.max),
                      ],
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Groups(
                              groups: widget.data.groups,
                              groupdets: widget.groupdets),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}

class Attendees extends StatelessWidget {
  Attendees({Key? key, required this.people}) : super(key: key);
  final Future<List<UserModel>> people;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: people,
        builder: (context, AsyncSnapshot<List<UserModel>> data) {
          print("ran");
          print(data.data.toString());
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.connectionState == ConnectionState.done
                  ? (data.hasData && data.data!.length != 0)
                      ? <Widget>[
                            Text(
                              "ATTENDEES",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] +
                          data.data!.map((item) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: ViewProfile(item),
                                    type: PageTransitionType.rightToLeft,
                                    duration: Duration(milliseconds: 200),
                                    reverseDuration:
                                        Duration(milliseconds: 200),
                                  ),
                                );
                              },
                              child: Text(
                                item.displayname,
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList()
                      : [Container()]
                  : [
                      Container(
                          child: Center(
                              child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      )))
                    ],
            ),
          );
        });
  }
}

class Groups extends StatelessWidget {
  const Groups({Key? key, required this.groups, required this.groupdets})
      : super(key: key);
  final List groups; //list of ids
  final List groupdets; //list of groupmodels
  @override
  Widget build(BuildContext context) {
    final List gidlist = groupdets.map((e) => e.gid).toList();
    final List filteredgids =
        groups.where((element) => gidlist.contains(element)).toList();
    final List filteredgdets = groupdets
        .where((element) => filteredgids.contains(element.gid))
        .toList();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Text(
                "GROUPS",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] +
            filteredgdets.map((item) {
              return Text(
                item.name,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
      ),
    );
  }
}

class Limit extends StatelessWidget {
  const Limit({Key? key, this.num, this.limit}) : super(key: key);
  final num;
  final limit;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "ATTENDEE LIMIT",
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            num.toString() + "/" + limit.toString(),
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class FancyStartEnd extends StatelessWidget {
  const FancyStartEnd({Key? key, this.start, this.end, this.duration})
      : super(key: key);
  final start;
  final end;
  final duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RotatedBox(
          quarterTurns: 3,
          child: Column(
            children: [
              Text(
                start,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "START",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.primary,
            thickness: 1.3,
            indent: 13,
            endIndent: 13,
          ),
        ),
        Text(
          duration,
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.primary,
            thickness: 1.3,
            indent: 13,
            endIndent: 13,
          ),
        ),
        RotatedBox(
          quarterTurns: 1,
          child: Column(
            children: [
              Text(
                end,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "FINISH",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final username;
  final button;
  final sid;
  final onTap;
  final checkmax;
  CustomAppBar(this.button, this.sid, this.onTap, this.username, this.checkmax);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(),
              !checkmax
                  ? (button == 0
                      ? AddButton(sid, onTap, username)
                      : (button == 1 ? AddedButton(sid, onTap) : EditButton()))
                  : button == 1
                      ? AddedButton(sid, onTap)
                      : Container(),
            ],
          ),
        ],
      ),
    );
  }
}

class BackButton extends StatelessWidget {
  // final onTodayPress;
  // GreenButton(this.onTodayPress);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 22,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          // splashColor: Color(0xff000000),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class AddButton extends StatefulWidget {
  final sid;
  final username;
  final onTap;

  AddButton(this.sid, this.onTap, this.username);

  @override
  _AddButtonState createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  var loader = false;

  Future addToSesh(uid, username) async {
    Future<bool> check() async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        return true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        return true;
      }
      return false;
    }

    var ret = 0;
    await check().then((intenet) async {
      if (intenet) {
        print("Internet available");
        await FirestoreService()
            .addMeToSession(widget.sid, uid, username)
            .then((value) {
          print(value);
          var snackbar = SnackBar(
              content: Text("${value[1]}"),
              // padding: EdgeInsets.all(8),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              backgroundColor: Theme.of(context).colorScheme.surface);
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
          if (value[0] == 1) {
            ret = 1;
          }
        });
      } else {
        var snackbar = SnackBar(
            content: Text("No internet"),
            // padding: EdgeInsets.all(8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            backgroundColor: Theme.of(context).colorScheme.surface);
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    });
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    return SizedBox(
      height: 47.0,
      width: 47.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          // border: Border.all(
          //   color: Color(0xffA65CE8),
          // ),
        ),
        child: Material(
          color: Theme.of(context).colorScheme.primaryVariant,
          borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: loader
                ? Center(
                    child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        )),
                  )
                : Icon(
                    LineIcons.plus,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            // splashColor: Color(0xff000000),
            onTap: () {
              setState(() {
                loader = true;
              });
              addToSesh(uid, widget.username).then((value) {
                print(value);
                setState(() {
                  loader = false;
                });
                if (value == 1) {
                  widget.onTap();
                }
              });
            },
          ),
        ),
      ),
    );
  }
}

class AddedButton extends StatelessWidget {
  final sid;
  AddedButton(this.sid, this.onTap);
  final onTap;

  @override
  Widget build(BuildContext context) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    return SizedBox(
      height: 47.0,
      width: 47.0,
      child: Container(
        child: Material(
          color: Theme.of(context).colorScheme.primaryVariant,
          borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Icon(
              Icons.check,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            // splashColor: Color(0xff000000),
            onTap: () {
              FirestoreService().removeMeFromSession(sid, uid);
              onTap();
            },
          ),
        ),
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  // final onTodayPress;
  // GreenButton(this.onTodayPress);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47.0,
      width: 47.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Material(
          color: Theme.of(context).colorScheme.primaryVariant,
          borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Icon(
              LineIcons.pen,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            // splashColor: Color(0xff000000),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}
