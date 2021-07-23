// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:testproj/pages/editprofile.dart';
import 'package:testproj/pages/groupdetails.dart';
import 'package:testproj/util/models.dart';
import 'package:testproj/widgets/grouplistitem.dart';

import 'package:testproj/pages/creategroup.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 28, right: 28),
        child: Column(
          children: [
            CustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ProfileCard(),
                      ],
                    ),
                    SizedBox(
                      height: 23,
                    ),
                    Row(
                      children: [
                        DiscordSection(),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Row(
                      children: [
                        SteamSection(),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Row(
                      children: [
                        EpicSection(),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Row(
                      children: [
                        StatsSection(),
                      ],
                    ),
                    SizedBox(
                      height: 9,
                    ),
                    Divider(),
                    SizedBox(
                      height: 9,
                    ),
                    Row(
                      children: [
                        SearchBox(controller: _textController),
                        AddButton()
                      ],
                    ),
                    SizedBox(height: 15.0),
                    GroupsList(controller: _textController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  // final onTodayPress;
  // CustomAppBar(this.onTodayPress);

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
                "Profile",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              EditButton()
            ],
          ),
        ],
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  // final onTodayPress;
  // GreenButton(this.onTodayPress);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserModel>(context);
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
              Icons.settings,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            // splashColor: Color(0xff000000),
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  child: EditProfilePage(user: user),
                  type: PageTransitionType.rightToLeft,
                  duration: Duration(milliseconds: 200),
                  reverseDuration: Duration(milliseconds: 200),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _user = Provider.of<UserModel>(context);

    return Expanded(
      child: Container(
          height: 93, //154 previously
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Color(_user.color)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: (_user != null)
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                "https://placedog.net/500/500?random"),
                            radius: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Container(
                              height: 60,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _user.displayname,
                                    style: GoogleFonts.poppins(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "@${_user.username}",
                                    style: GoogleFonts.poppins(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       mainAxisAlignment: MainAxisAlignment.end,
                      //       children: [
                      //         Padding(
                      //           padding: const EdgeInsets.only(bottom: 0.0),
                      //           child: Text(
                      //             _user.numconn,
                      //             style: GoogleFonts.poppins(
                      //               color:
                      //                   Theme.of(context).colorScheme.surface,
                      //               fontSize: 16.0,
                      //               fontWeight: FontWeight.w600,
                      //             ),
                      //           ),
                      //         ),
                      //         Text(
                      //           "connections",
                      //           textAlign: TextAlign.end,
                      //           style: GoogleFonts.poppins(
                      //             color: Theme.of(context).colorScheme.surface,
                      //             fontSize: 12.0,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     Column(
                      //       children: [
                      //         PotentialButton(),
                      //       ],
                      //     )
                      //   ],
                      // )
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                )),
    );
  }
}

class PotentialButton extends StatelessWidget {
  // final onTodayPress;
  // Greencolor(this.onTodayPress);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color.fromRGBO(24, 24, 24, 0.1),
            ),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextButton.icon(
              icon: Icon(
                Icons.arrow_back,
                size: 20,
              ),
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 16.0, right: 12.0),
                  primary: Theme.of(context).colorScheme.surface,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  )),
              label: Text('Potentials'),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class EpicSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _user = Provider.of<UserModel>(context);
    return Expanded(
      child: Container(
        child: (_user != null)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _user.foreigntags['epic'] == ""
                    ? [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "EPIC GAMES",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Add Epic in settings",
                              style: GoogleFonts.poppins(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ]
                    : [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "EPIC GAMES",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${_user.foreigntags['epic']}",
                              style: GoogleFonts.poppins(
                                color: Color(_user.color),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextButton.icon(
                            icon: Icon(
                              Icons.content_copy,
                              size: 16,
                            ),
                            style: TextButton.styleFrom(
                                primary:
                                    Theme.of(context).colorScheme.onSurface,
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                )),
                            label: Text('Copy'),
                            onPressed: () {},
                          ),
                        ),
                      ],
              )
            : Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ),
    );
  }
}

class SteamSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _user = Provider.of<UserModel>(context);
    return Expanded(
      child: Container(
        child: (_user != null)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _user.foreigntags['steam'] == ""
                    ? [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "STEAM",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Add Steam in settings",
                              style: GoogleFonts.poppins(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ]
                    : [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "STEAM",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${_user.foreigntags['steam']}",
                              style: GoogleFonts.poppins(
                                color: Color(_user.color),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextButton.icon(
                            icon: Icon(
                              Icons.content_copy,
                              size: 16,
                            ),
                            style: TextButton.styleFrom(
                                primary:
                                    Theme.of(context).colorScheme.onSurface,
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                )),
                            label: Text('Copy'),
                            onPressed: () {},
                          ),
                        ),
                      ],
              )
            : Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ),
    );
  }
}

class DiscordSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _user = Provider.of<UserModel>(context);
    return Expanded(
      child: Container(
        child: (_user != null)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _user.foreigntags['discord'] == ""
                    ? [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DISCORD",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Add Discord in settings",
                              style: GoogleFonts.poppins(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ]
                    : [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DISCORD",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${_user.foreigntags['discord']}",
                              style: GoogleFonts.poppins(
                                color: Color(_user.color),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextButton.icon(
                            icon: Icon(
                              Icons.content_copy,
                              size: 16,
                            ),
                            style: TextButton.styleFrom(
                                primary:
                                    Theme.of(context).colorScheme.onSurface,
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                )),
                            label: Text('Copy'),
                            onPressed: () {},
                          ),
                        ),
                      ],
              )
            : Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ),
    );
  }
}

class StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _user = Provider.of<UserModel>(context);

    return Expanded(
      child: Container(
        child: _user != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "STATS",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0.0),
                                child: Text(
                                  "${_user.numsessions}",
                                  style: GoogleFonts.poppins(
                                    color: Color(_user.color),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                "sessions",
                                textAlign: TextAlign.end,
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 0.0),
                                  child: Text(
                                    "${_user.hours}",
                                    style: GoogleFonts.poppins(
                                      color: Color(_user.color),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  "hours",
                                  textAlign: TextAlign.end,
                                  style: GoogleFonts.poppins(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: Text(
                                "${_user.mostplayed}",
                                style: GoogleFonts.poppins(
                                  color: Color(_user.color),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              "most played",
                              textAlign: TextAlign.end,
                              style: GoogleFonts.poppins(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Directionality(
                  //   textDirection: TextDirection.rtl,
                  //   child: TextButton.icon(
                  //     icon: Icon(
                  //       Icons.arrow_back,
                  //       size: 16,
                  //     ),
                  //     style: TextButton.styleFrom(
                  //         primary: Theme.of(context).colorScheme.onSurface,
                  //         textStyle: GoogleFonts.poppins(
                  //           fontSize: 12.0,
                  //           fontWeight: FontWeight.w600,
                  //         )),
                  //     label: Text('Full Stats'),
                  //     onPressed: () {},
                  //   ),
                  // ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ),
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
    return Expanded(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: TextField(
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
          ),
          decoration: InputDecoration(
            fillColor: Color(0xff181818),
            hintText: 'Groups',
            suffixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            hintStyle: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 18.0,
            ),
            border: InputBorder.none,
          ),
          controller: widget.controller,
          cursorColor: Theme.of(context).colorScheme.onBackground,
          textInputAction: TextInputAction.search,
        ),
      ),
    );
  }
}

class GroupsList extends StatefulWidget {
  const GroupsList({Key? key, required this.controller}) : super(key: key);
  final TextEditingController controller;

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

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<GroupModel> groups = Provider.of<List<GroupModel>>(context);
    List<GroupModel> groupsfiltered = List.from(groups);
    if (widget.controller.text != "") {
      groupsfiltered = groups
          .where((item) => item.name
              .toLowerCase()
              .contains(widget.controller.text.toLowerCase()))
          .toList();
    }

    return Column(
      children: groupsfiltered.length > 0
          ? groupsfiltered.map((item) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: GroupDetailsPage(group: item),
                      type: PageTransitionType.rightToLeft,
                      duration: Duration(milliseconds: 200),
                      reverseDuration: Duration(milliseconds: 200),
                    ),
                  );
                },
                child: ListItem(
                  item.users.length,
                  item.name,
                  item.creator,
                ),
              );
            }).toList()
          : [Container()],
    );
  }
}

class AddButton extends StatelessWidget {
  // final onTodayPress;
  // Greencolor(this.onTodayPress);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47.0,
      width: 47.0,
      child: Container(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Icon(
              LineIcons.plus,
              size: 28,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            // splashColor: Color(0xff000000),
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  child: CreateGroupPage(),
                  type: PageTransitionType.rightToLeft,
                  duration: Duration(milliseconds: 200),
                  reverseDuration: Duration(milliseconds: 200),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
