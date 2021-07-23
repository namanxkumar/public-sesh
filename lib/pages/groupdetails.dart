import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:testproj/pages/sharelink.dart';
import 'package:testproj/pages/viewprofile.dart';
import 'package:testproj/util/firestore.dart';
import 'package:testproj/util/models.dart';

class GroupDetailsPage extends StatefulWidget {
  const GroupDetailsPage({Key? key, required this.group}) : super(key: key);
  final GroupModel group;

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  var _db = FirebaseFirestore.instance;
  Future<List<UserModel>> getPeople(people) async {
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

  _leaveGroup(gid, name) async {
    cancel() {
      return Navigator.pop(context, 0);
    }

    confirm() {
      return Navigator.pop(context, 1);
    }

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      content: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.primary
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure you want to leave $name?",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "You will have request another invite link to rejoin",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                noButton(onPressed: cancel),
                yesButton(onPressed: confirm),
              ],
            )
          ],
        ),
      ),
      contentPadding: EdgeInsets.all(0.0),
    );
    var ret = await showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
    if (ret == 1) {
      setState(() {
        _loading = true;
      });
      var ret2 = await FirestoreService().removeMeFromGroup(gid);
      if (ret2[0] == 1) {
        var snackbar = SnackBar(
            content: Text("${ret2[1]}"),
            // padding: EdgeInsets.all(8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            backgroundColor: Theme.of(context).colorScheme.surface);
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.pop(context);
      } else {
        var snackbar = SnackBar(
            content: Text("An error occurred"),
            // padding: EdgeInsets.all(8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            backgroundColor: Theme.of(context).colorScheme.surface);
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.pop(context);
      }
    }
  }

  onSubmit() {}
  var _loading = false;
  @override
  Widget build(BuildContext context) {
    final people = getPeople(widget.group.users);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 28, right: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                isCreator: FirebaseAuth.instance.currentUser!.uid ==
                    widget.group.creator,
                gid: widget.group.gid,
                link: widget.group.link,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.group.name}",
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: FutureBuilder(
                              future: people,
                              builder: (context,
                                      AsyncSnapshot<List<UserModel>>
                                          snapshot) =>
                                  Text(
                                snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData &&
                                        snapshot.data!.length != 0
                                    ? "Creator: @" +
                                        snapshot.data!
                                            .where((id) =>
                                                id.uid == widget.group.creator)
                                            .toList()[0]
                                            .username
                                    : "Creator: @username",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "DESCRIPTION",
                                  style: GoogleFonts.poppins(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                                Text(
                                  "${widget.group.description}",
                                  style: GoogleFonts.poppins(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Attendees(people: people),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FirebaseAuth.instance.currentUser!.uid ==
                              widget.group.creator
                          ? Container()
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton(
                                  onPressed: _loading
                                      ? () {}
                                      : () {
                                          _leaveGroup(widget.group.gid,
                                              widget.group.name);
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
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  child: _loading
                                      ? Text("Loading...")
                                      : Text("Leave group"),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class noButton extends StatelessWidget {
  const noButton({Key? key, required this.onPressed}) : super(key: key);
  final onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        padding:
            EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
        primary: Colors.transparent,
        shadowColor: Colors.transparent,
        onPrimary: Theme.of(context).colorScheme.onBackground,
        textStyle: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.w600,
          fontSize: 16.0,
        ),
      ),
      child: Icon(Icons.close),
    );
  }
}

class yesButton extends StatelessWidget {
  const yesButton({Key? key, required this.onPressed}) : super(key: key);
  final onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        padding:
            EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
        primary: Colors.transparent,
        shadowColor: Colors.transparent,
        onPrimary: Theme.of(context).colorScheme.onBackground,
        textStyle: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.w600,
          fontSize: 16.0,
        ),
      ),
      child: Icon(Icons.check),
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
                              "MEMBERS",
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

class CustomAppBar extends StatelessWidget {
  final isCreator;
  final gid;
  final link;
  CustomAppBar(
      {required this.isCreator, required this.gid, required this.link});

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
              Row(
                children: [
                  BackButton(),
                  Text(
                    "Group",
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              isCreator ? CheckButton(gid, link) : Container()
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
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
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
              color: Theme.of(context).colorScheme.primary,
            ),
            // splashColor: Color(0xff000000),
          ),
        ),
      ),
    );
  }
}

class CheckButton extends StatelessWidget {
  final gid;
  final link;
  CheckButton(this.gid, this.link);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryVariant,
                  border:
                      Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
              // primary: Theme.of(context).colorScheme.primary,
              textStyle: Theme.of(context).textTheme.button,
            ),
            child: Text('Invite'),
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  child: ShareLink(gid: gid, link: link),
                  type: PageTransitionType.rightToLeft,
                  duration: Duration(milliseconds: 200),
                  reverseDuration: Duration(milliseconds: 200),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
