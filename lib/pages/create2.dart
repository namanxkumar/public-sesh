import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:testproj/homepage.dart';
import 'package:testproj/util/models.dart';
import 'package:testproj/widgets/createsessgrouplistitem.dart';

class SelectGroupScreen extends StatefulWidget {
  const SelectGroupScreen(
      {Key? key,
      this.startData,
      this.endData,
      this.groups,
      this.maxData,
      this.gameData,
      this.username})
      : super(key: key);
  final startData;
  final endData;
  final gameData;
  final groups;
  final maxData;
  final username;

  @override
  _SelectGroupScreenState createState() => _SelectGroupScreenState();
}

class _SelectGroupScreenState extends State<SelectGroupScreen> {
  TextEditingController controller = TextEditingController();
  Map<int, GroupModel> current = {};
  onSelect(int key, GroupModel value) {
    print(value);
    setState(() {
      if (!current.values.contains(value)) {
        current[key] = value;
      } else {
        current.remove(key);
      }
      print(current);
    });
  }

  onSubmit() async {
    if (current.length == 0) {
      var snackbar = SnackBar(
          content: Text("Select a group"),
          // padding: EdgeInsets.all(8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          backgroundColor: Theme.of(context).colorScheme.surface);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } else {
      var _firestore = FirebaseFirestore.instance;
      var auth = FirebaseAuth.instance;
      Navigator.push(
        context,
        PageTransition(
          child: Loader(),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 200),
        ),
      );
      try {
        await _firestore.collection("sessions").add({
          'creator': auth.currentUser!.uid,
          'start': widget.startData,
          'end': widget.endData,
          'game': widget.gameData,
          'groups': current.values.map((e) => e.gid).toList(),
          'max': widget.maxData,
          'users': [auth.currentUser!.uid]
        }).then((value) => Navigator.push(
              context,
              PageTransition(
                child: MyHomePage(),
                type: PageTransitionType.rightToLeft,
                duration: Duration(milliseconds: 200),
                reverseDuration: Duration(milliseconds: 200),
              ),
            ));
      } on Exception catch (e) {
        // TODO
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.only(left: 28, right: 28),
          child: Column(
            children: [
              CustomAppBar(onSubmit),
              SizedBox(height: 15.0),
              SearchBox(controller: controller),
              SizedBox(height: 15.0),
              GroupsList(
                  controller: controller,
                  groups: widget.groups,
                  onPress: onSelect,
                  current: current)
            ],
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

class GroupsList extends StatefulWidget {
  const GroupsList(
      {Key? key,
      required this.controller,
      required this.groups,
      required this.onPress,
      required this.current})
      : super(key: key);
  final TextEditingController controller;
  final List<GroupModel> groups;
  final Function onPress;
  final current;
  @override
  _GroupsListState createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  var data;

  @override
  Widget build(BuildContext context) {
    List<GroupModel> groups = widget.groups;
    List<GroupModel> groupsfiltered = List.from(groups);
    data = List.generate(groupsfiltered.length, (index) => 0);
    if (widget.controller.text != "") {
      groupsfiltered = groups
          .where((item) => item.name
              .toLowerCase()
              .contains(widget.controller.text.toLowerCase()))
          .toList();
    }

    return Column(
      children: groupsfiltered.length > 0
          ? groupsfiltered
              .asMap()
              .map((key, value) {
                return MapEntry(
                    key,
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (data[key] == 1) {
                            data[key] = data[key] == 1 ? 0 : 1;
                          } else {
                            data.forEach((element) => element = 0);
                            data[key] = 1;
                          }
                          widget.onPress(key, value);
                          setState(() {});
                        },
                        child: ListItem(value.users.length, value.name,
                            widget.current[key] != null ? true : false),
                      ),
                    ));
              })
              .values
              .toList()
          : [Container()],
    );
  }
}

class SearchBox extends StatefulWidget {
  SearchBox({Key? key, required this.controller}) : super(key: key);
  final controller;

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: Color(0xff181818)),
      child: TextField(
        style: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.w500,
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          fillColor: Color(0xff181818),
          hintText: 'Search',
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          hintStyle: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
          ),
          focusColor: Theme.of(context).colorScheme.primary,
          border: InputBorder.none,
        ),
        controller: widget.controller,
        cursorColor: Theme.of(context).colorScheme.primary,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final onSub;
  CustomAppBar(this.onSub);

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
              Text(
                "Select groups",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [CheckButton(onSub)],
                  ),
                ],
              ), //ontodaypress
            ],
          )
        ],
      ),
    );
  }
}

class CheckButton extends StatefulWidget {
  final onSubmit;
  CheckButton(this.onSubmit);

  // final onTodayPress;
  // GreenButton(this.onTodayPress);

  @override
  _CheckButtonState createState() => _CheckButtonState();
}

class _CheckButtonState extends State<CheckButton> {
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
              Icons.check,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            // splashColor: Color(0xff000000),
            onTap: widget.onSubmit,
          ),
        ),
      ),
    );
  }
}
