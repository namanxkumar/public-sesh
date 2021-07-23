import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:testproj/util/firestore.dart';
import 'package:testproj/util/models.dart';

class ListItem extends StatelessWidget {
  ListItem(this.data);
  final _auth = FirebaseAuth.instance;
  final SessionModel data;

  @override
  Widget build(BuildContext context) {
    final button = data.creator == _auth.currentUser?.uid
        ? 2
        : (data.users.contains(_auth.currentUser?.uid) ? 1 : 0);
    var groups = Provider.of<List<GroupModel>>(context);
    final List gidlist = groups.map((e) => e.gid).toList();
    final List filteredgids =
        data.groups.where((element) => gidlist.contains(element)).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 137,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    data.start.compareTo(DateTime.now()) < 0 &&
                            data.end.compareTo(DateTime.now()) > 0
                        ? "Now"
                        : data.start.hour.toString() +
                            ":" +
                            data.start.minute.toString(),
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  child: Text(
                    data.start.compareTo(DateTime.now()) < 0 &&
                            data.end.compareTo(DateTime.now()) > 0
                        ? ""
                        : data.end.hour.toString() +
                            ":" +
                            data.end.minute.toString(),
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Container(
                height: 137,
                width: 250,
                child: Stack(
                  children: [
                    Container(
                      height: 137,
                      width: 250,
                      decoration: button == 1
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.surface,
                                    Theme.of(context).colorScheme.primary
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              // color: Theme.of(context).colorScheme.surface,
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.black,
                              //     offset: const Offset(0, 1),
                              //     blurRadius: 2.0,
                              //   )
                              // ],
                            )
                          : BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: Colors.transparent,
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary)
                              // color: Theme.of(context).colorScheme.surface,
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.black,
                              //     offset: const Offset(0, 1),
                              //     blurRadius: 2.0,
                              //   )
                              // ],
                              ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0.0, bottom: 4.0),
                                          child: Text(
                                            data.game,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                                color: button == 1
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onBackground
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Text(
                                          filteredgids.length > 1
                                              ? groups
                                                      .where((element) =>
                                                          element.gid ==
                                                          filteredgids[0])
                                                      .toList()[0]
                                                      .name +
                                                  " + " +
                                                  (filteredgids.length - 1)
                                                      .toString()
                                              : (filteredgids.length > 0
                                                  ? groups
                                                      .where((element) =>
                                                          element.gid ==
                                                          filteredgids[0])
                                                      .toList()[0]
                                                      .name
                                                  : ""),
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "https://placedog.net/500/500?random"),
                                  radius: 14,
                                ),
                                Text(
                                  data.users.length.toString() +
                                      "/" +
                                      data.max.toString(),
                                  style: GoogleFonts.poppins(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                          child: data.users.length != data.max
                              ? (button == 0
                                  ? AddButton(data.sid)
                                  : (button == 1
                                      ? AddedButton(data.sid)
                                      : EditButton()))
                              : button == 1
                                  ? AddedButton(data.sid)
                                  : Container(),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AddButton extends StatefulWidget {
  final sid;
  // final changeButton;
  AddButton(this.sid);

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
    var user = Provider.of<UserModel>(context);
    return SizedBox(
      height: 40.0,
      width: 40.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          // border: Border.all(
          //   color: Color(0xffA65CE8),
          // ),
        ),
        child: Material(
          color: Colors.transparent,
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
              addToSesh(user.uid, user.username).then((value) {
                print(value);
                setState(() {
                  loader = false;
                });
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
  AddedButton(this.sid);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserModel>(context);
    return SizedBox(
      height: 40.0,
      width: 40.0,
      child: Container(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Icon(
              Icons.check,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            // splashColor: Color(0xff000000),
            onTap: () {
              FirestoreService().removeMeFromSession(sid, user.uid);
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
      height: 40.0,
      width: 40.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Material(
          color: Colors.transparent,
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
