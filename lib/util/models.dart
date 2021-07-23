// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:testproj/util/firestore.dart';

class UserModel {
  final String displayname;
  final String email;
  final String username;
  final String numconn;
  final Map foreigntags;
  final String numsessions;
  final String hours;
  final String mostplayed;
  final int color;
  final List groups;
  final String uid;
  final List recents;

  UserModel(
      {required this.numsessions,
      required this.hours,
      required this.mostplayed,
      required this.displayname,
      required this.email,
      required this.username,
      required this.numconn,
      required this.foreigntags,
      required this.color,
      required this.groups,
      required this.uid,
      required this.recents});

  UserModel.fromFirestore(Map<String, dynamic>? firestore)
      : displayname = firestore?['name'] ?? "Sesher",
        email = firestore?['email'] ?? "someone@email.com",
        username = firestore?['username'] ?? "gamertag",
        numconn = firestore?['numconn'].toString() ?? "0",
        foreigntags = firestore?['foreigntags'] ?? {},
        numsessions = firestore?['numsessions'] == null
            ? "-"
            : firestore!['numsessions'].toString(),
        hours = firestore?['hours'] == null ? "-" : firestore!['hours'],
        mostplayed =
            firestore?['mostplayed'] == null ? "-" : firestore!['mostplayed'],
        color = firestore?['color'] == null
            ? int.parse("0xffE9CE2C")
            : int.parse(firestore?['color']),
        groups = firestore?['groups'] ?? [],
        uid = firestore?['uid'] ?? "",
        recents = firestore?['recents'] ?? [];
}

class GroupModel {
  final String creator;
  final String description;
  final String name;
  final List users;
  final String gid;
  final String link;
  final String linkid;

  GroupModel(
      {required this.creator,
      required this.description,
      required this.name,
      required this.users,
      required this.gid,
      required this.link,
      required this.linkid});

  GroupModel.fromFirestore(Map<String, dynamic>? firestore, gid)
      : creator = firestore?['creator'] ?? "",
        description = firestore?['description'] ?? "",
        name = firestore?['name'] ?? "Group",
        users = firestore?['users'] ?? [],
        gid = gid,
        link = firestore?['link'] ?? "",
        linkid = firestore?['pagelink'] ?? "";
}

class SessionModel {
  final String game;
  final DateTime start;
  final DateTime end;
  final Duration duration;
  final int max;
  final List users;
  final String creator;
  final List groups;
  final String sid;

  SessionModel(
      {required this.game,
      required this.start,
      required this.end,
      required this.duration,
      required this.max,
      required this.users,
      required this.creator,
      required this.groups,
      required this.sid});

  SessionModel.fromFirestore(Map<String, dynamic>? firestore, sid)
      : game = firestore?['game'] ?? "Game",
        start = DateTime.parse(
            firestore?['start'].toDate().toString() ?? "2021-09-06 00:00:00"),
        end = DateTime.parse(
            firestore?['end'].toDate().toString() ?? "2021-09-06 00:00:00"),
        duration = DateTime.parse(
                firestore?['end'].toDate().toString() ?? "2021-09-06 00:00:00")
            .difference(DateTime.parse(
                firestore?['start'].toDate().toString() ??
                    "2021-09-06 00:00:00")),
        max = firestore?['max'] ?? 0,
        users = firestore?['users'] ?? [],
        creator = firestore?['creator'] ?? "",
        groups = firestore?['groups'] ?? [],
        sid = sid ?? "";
}

class SessonListModel {
  List<SessionModel>? _posts;
  List<SessionModel>? get posts => _posts;
  void listenToSessions() {
    FirestoreService().listenToPostsRealTime().listen((sessionData) {
      List<SessionModel>? updatedSessions = sessionData;
      if (updatedSessions != null && updatedSessions.length > 0) {
        _posts = updatedSessions;
      }
    });
  }
}
