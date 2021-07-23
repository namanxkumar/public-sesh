// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testproj/util/models.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class ViewProfile extends StatefulWidget {
  final UserModel user;
  ViewProfile(this.user);
  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
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
                          ProfileCard(widget.user),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      widget.user.foreigntags['discord'] == ""
                          ? Container()
                          : Column(
                              children: [
                                SizedBox(
                                  height: 23,
                                ),
                                Row(
                                  children: [
                                    DiscordSection(widget.user),
                                  ],
                                ),
                              ],
                            ),
                      widget.user.foreigntags['steam'] == ""
                          ? Container()
                          : Column(
                              children: [
                                SizedBox(
                                  height: 18,
                                ),
                                Row(
                                  children: [
                                    SteamSection(widget.user),
                                  ],
                                ),
                              ],
                            ),
                      widget.user.foreigntags['epic'] == ""
                          ? Container()
                          : Column(
                              children: [
                                SizedBox(
                                  height: 18,
                                ),
                                Row(
                                  children: [
                                    EpicSection(widget.user),
                                  ],
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 18,
                      ),
                      // Row(
                      //   children: [
                      //     StatsSection(),
                      //   ],
                      // ),
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
              BackButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  ProfileCard(this._user);
  final _user;
  @override
  Widget build(BuildContext context) {
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
  EpicSection(this._user);
  final _user;
  @override
  Widget build(BuildContext context) {
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
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                      text: _user.foreigntags['epic']))
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Copied to clipboard")));
                              });
                            },
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
  SteamSection(this._user);
  final _user;
  @override
  Widget build(BuildContext context) {
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
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                      text: _user.foreigntags['steam']))
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Copied to clipboard")));
                              });
                            },
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
  DiscordSection(this._user);
  final _user;
  @override
  Widget build(BuildContext context) {
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
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                      text: _user.foreigntags['discord']))
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Copied to clipboard")));
                              });
                            },
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

// class StatsSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var _user = Provider.of<UserModel>(context);

//     return Expanded(
//       child: Container(
//         child: _user != null
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "STATS",
//                         style: GoogleFonts.poppins(
//                           color: Theme.of(context).colorScheme.onSurface,
//                           fontSize: 11.0,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(bottom: 0.0),
//                                 child: Text(
//                                   "${_user.numsessions}",
//                                   style: GoogleFonts.poppins(
//                                     color: Color(_user.color),
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                               Text(
//                                 "sessions",
//                                 textAlign: TextAlign.end,
//                                 style: GoogleFonts.poppins(
//                                   color: Theme.of(context)
//                                       .colorScheme
//                                       .onBackground,
//                                   fontSize: 12.0,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 30.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(bottom: 0.0),
//                                   child: Text(
//                                     "${_user.hours}",
//                                     style: GoogleFonts.poppins(
//                                       color: Color(_user.color),
//                                       fontSize: 16.0,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   "hours",
//                                   textAlign: TextAlign.end,
//                                   style: GoogleFonts.poppins(
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .onBackground,
//                                     fontSize: 12.0,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(bottom: 0.0),
//                               child: Text(
//                                 "${_user.mostplayed}",
//                                 style: GoogleFonts.poppins(
//                                   color: Color(_user.color),
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               "most played",
//                               textAlign: TextAlign.end,
//                               style: GoogleFonts.poppins(
//                                 color:
//                                     Theme.of(context).colorScheme.onBackground,
//                                 fontSize: 12.0,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   // Directionality(
//                   //   textDirection: TextDirection.rtl,
//                   //   child: TextButton.icon(
//                   //     icon: Icon(
//                   //       Icons.arrow_back,
//                   //       size: 16,
//                   //     ),
//                   //     style: TextButton.styleFrom(
//                   //         primary: Theme.of(context).colorScheme.onSurface,
//                   //         textStyle: GoogleFonts.poppins(
//                   //           fontSize: 12.0,
//                   //           fontWeight: FontWeight.w600,
//                   //         )),
//                   //     label: Text('Full Stats'),
//                   //     onPressed: () {},
//                   //   ),
//                   // ),
//                 ],
//               )
//             : Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),
//       ),
//     );
//   }
// }