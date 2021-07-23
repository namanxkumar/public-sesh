import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testproj/util/firestore.dart';
import 'package:testproj/util/models.dart';

class InviteLinkPage extends StatefulWidget {
  const InviteLinkPage({Key? key, required this.params}) : super(key: key);
  final Map params;

  @override
  _InviteLinkPageState createState() => _InviteLinkPageState();
}

class _InviteLinkPageState extends State<InviteLinkPage> {
  var _db = FirebaseFirestore.instance;
  GroupModel? group;
  var error = 0;
  Future<GroupModel?> getData() async {
    var snapshot =
        await _db.collection('groups').doc(widget.params['id']).get();
    if (snapshot.exists) {
      print('exists');
      return GroupModel.fromFirestore(snapshot.data(), snapshot.id);
    } else {
      setState(() {
        error = 1;
        var snackbar = SnackBar(
            content: Text("An error occurred"),
            // padding: EdgeInsets.all(8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            backgroundColor: Theme.of(context).colorScheme.surface);
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("im in invitelink page");
    var groupData = getData();
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 28, right: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: MainSection(groupData: groupData),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainSection extends StatefulWidget {
  const MainSection({Key? key, required this.groupData}) : super(key: key);
  final Future<GroupModel?> groupData;

  @override
  _MainSectionState createState() => _MainSectionState();
}

class _MainSectionState extends State<MainSection> {
  var ret;
  var _loading = false;
  var _done = 0;
  _joinGroup(gid) async {
    setState(() {
      _loading = true;
    });
    ret = await FirestoreService().addMeToGroup(gid);
    var snackbar = SnackBar(
        content: Text("${ret[1]}"),
        // padding: EdgeInsets.all(8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        backgroundColor: Theme.of(context).colorScheme.surface);
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
    setState(() {
      _loading = false;
      _done = ret[0] == 1 ? 2 : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.groupData,
        builder: (context, AsyncSnapshot<GroupModel?> snapshot) {
          return snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData
              ? Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("You have been invited to:"),
                      Text(
                        "${snapshot.data?.name ?? "error"}",
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      _done == 2
                          ? Column(
                              children: [
                                Icon(Icons.check_circle),
                                Text(ret[1],
                                    style: GoogleFonts.poppins(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        fontSize: 14))
                              ],
                            )
                          : _done == 1
                              ? Column(
                                  children: [
                                    Icon(Icons.error),
                                    Text(ret[1],
                                        style: GoogleFonts.poppins(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            fontSize: 14))
                                  ],
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    _joinGroup(snapshot.data!.gid);
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
                                      : Text("Join"),
                                )
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
        });
  }
}
