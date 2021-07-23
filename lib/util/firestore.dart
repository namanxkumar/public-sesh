import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:testproj/pages/sessions.dart';
import 'models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<UserModel> getUser() {
    return _db
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .map((value) => UserModel.fromFirestore(value.data()));
  }

  Stream<List<GroupModel>> getGroups() {
    return _db
        .collection('groups')
        .where('users', arrayContains: _auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      print(snapshot.docs.toList());
      return snapshot.docs.map((e) {
        print(e.data());
        return GroupModel.fromFirestore(e.data(), e.id);
      }).toList();
    });
  }

  DocumentSnapshot? _lastDocument;
  bool _hasMorePosts = true;
  List<List<SessionModel>> _allPagedResults =
      List<List<SessionModel>>.empty(growable: true);
  static const PostsLimit = 10;

  void getSessions({special}) async {
    if (special != null && special) {
      _lastDocument = null;
      _hasMorePosts = true;
      _allPagedResults = List<List<SessionModel>>.empty(growable: true);
    }
    print("getting sessions... $_lastDocument");
    List arrGroup = await _db
        .collection('groups')
        .where('users', arrayContains: _auth.currentUser!.uid)
        .get()
        .then((value) => value.docs
            .map((e) => GroupModel.fromFirestore(e.data(), e.id).gid)
            .toList());
    print(arrGroup);
    print("Stuff" + _allPagedResults.toString());
    var query = _db
        .collection('sessions')
        .where('groups', arrayContainsAny: arrGroup)
        .where('start',
            isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(
                hours: DateTime.now().hour,
                minutes: DateTime.now().minute,
                seconds: DateTime.now().second,
                milliseconds: DateTime.now().millisecond,
                microseconds: DateTime.now().microsecond)))
        .orderBy('start')
        .limit(PostsLimit);
    //   .snapshots()
    //   .map((value) {
    // return value.docs
    //     .map((e) => SessionModel.fromFirestore(e.data()))
    //     .toList();
    // }
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }
    if (!_hasMorePosts) return null;
    var currentRequestIndex = _allPagedResults.length;
    query.snapshots().listen((snapshot) async {
      var sessions = snapshot.docs
          .map((e) => SessionModel.fromFirestore(e.data(), e.id))
          .toList();
      var pageExists = currentRequestIndex < _allPagedResults.length;
      if (pageExists) {
        _allPagedResults[currentRequestIndex] = sessions;
      } else {
        _allPagedResults.add(sessions);
      }
      var allSessions = _allPagedResults.fold<List<SessionModel>>(
          List<SessionModel>.empty(growable: true),
          (initialValue, pageItems) => initialValue..addAll(pageItems));
      print(allSessions);
      _sessionController.sink.add(List.from(allSessions));
      if (currentRequestIndex == _allPagedResults.length - 1) {
        _lastDocument = snapshot.docs.last;
      }

      _hasMorePosts = sessions.length == PostsLimit;
    });
  }

  Stream<List<SessionModel>> listenToPostsRealTime() {
    // Register the handler for when the posts data changes
    getSessions();
    return _sessionController.stream;
  }

  final StreamController<List<SessionModel>> _sessionController =
      StreamController<List<SessionModel>>.broadcast();

  Future addMeToSession(sid, uid, username) {
    DocumentReference docRef = _db.collection('sessions').doc(sid);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      SessionModel model = SessionModel.fromFirestore(
          snapshot.data() as Map<String, dynamic>?, sid);
      if (!snapshot.exists) {
        throw Exception("Session does not exist");
      } else if (model.users.length == model.max) {
        throw Exception("Session is at max capacity");
      } else {
        transaction.update(docRef, {
          "users": FieldValue.arrayUnion([uid])
        });
      }
      return model.game;
    }).then((value) {
      return [1, "Added to session"];
    }).catchError((e) {
      return [0, "${e}"];
    }, test: (e) => e is Exception);
  }

  void removeMeFromSession(sid, uid) {
    _db.collection('sessions').doc(sid).update({
      "users": FieldValue.arrayRemove([uid])
    });
  }

  void updateBasicProfile(color, display, discord, steam, epic) {
    _db.collection('users').doc(_auth.currentUser!.uid).update({
      "color": color.toString(),
      "name": display,
      "foreigntags.discord": discord,
      "foreigntags.steam": steam,
      "foreigntags.epic": epic
    });
  }

  Future createGroup(name, description) {
    DocumentReference docRef =
        _db.collection('users').doc(_auth.currentUser!.uid);
    DocumentReference docRef2 = _db.collection('groups').doc();
    return FirebaseFirestore.instance
        .runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(docRef);
          UserModel model =
              UserModel.fromFirestore(snapshot.data() as Map<String, dynamic>?);
          if (!snapshot.exists) {
            throw Exception("Failed");
          } else if (model.groups.length == 10) {
            throw Exception("You can only be in 10 groups");
          } else {
            transaction.set(docRef2, {
              "creator": _auth.currentUser!.uid,
              "name": name,
              "description": description,
              "users": [_auth.currentUser!.uid]
            });
            transaction.update(docRef, {
              "groups": FieldValue.arrayUnion([docRef2.id])
            });
          }
          return name;
        })
        .then((value) => [1, "Group created"])
        .catchError((e) {
          return [0, "An error occurred, check your internet connection"];
        }, test: (e) => e is PlatformException)
        .catchError((e) {
          return [0, "${e}"];
        }, test: (e) => e is Exception);
  }

  Future updateGroupLink(pagelink, url, gid) async {
    return _db
        .collection('groups')
        .doc(gid)
        .update({"pagelink": pagelink, "link": url}).then((value) {
      return pagelink;
    });
  }

  Future addMeToGroup(gid) async {
    DocumentReference docRef =
        _db.collection('users').doc(_auth.currentUser!.uid);
    DocumentReference docRef2 = _db.collection('groups').doc(gid);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      DocumentSnapshot snapshot2 = await transaction.get(docRef2);
      UserModel model =
          UserModel.fromFirestore(snapshot.data() as Map<String, dynamic>?);
      GroupModel group = GroupModel.fromFirestore(
          snapshot2.data() as Map<String, dynamic>?, gid);
      if (!snapshot.exists) {
        throw Exception("Failed");
      } else if (model.groups.contains(gid)) {
        throw Exception("You're already in this group");
      } else if (model.groups.length == 10) {
        throw Exception("You can only be in 10 groups");
      } else if (group.users.length == 15) {
        throw Exception("Group is at max capacity");
      } else {
        transaction.update(docRef2, {
          "users": FieldValue.arrayUnion([_auth.currentUser!.uid]),
        });
        transaction.update(docRef, {
          "groups": FieldValue.arrayUnion([docRef2.id])
        });
        this.getSessions(special: true);
      }
      return 1;
    }).then((value) {
      return [1, "Added to group"];
    }).catchError((e) {
      return [0, "An error occurred, check your internet connection"];
    }, test: (e) => e is PlatformException).catchError((e) {
      return [0, "${e.toString()}"];
    }, test: (e) => e is Exception);
  }

  Future removeMeFromGroup(gid) async {
    DocumentReference docRef =
        _db.collection('users').doc(_auth.currentUser!.uid);
    DocumentReference docRef2 = _db.collection('groups').doc(gid);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      DocumentSnapshot snapshot2 = await transaction.get(docRef2);
      UserModel model =
          UserModel.fromFirestore(snapshot.data() as Map<String, dynamic>?);
      GroupModel group = GroupModel.fromFirestore(
          snapshot2.data() as Map<String, dynamic>?, gid);
      if (!snapshot.exists) {
        throw Exception("Failed");
      } else if (!model.groups.contains(gid)) {
        throw Exception("Failed");
      } else if (model.uid == group.creator) {
        throw Exception("Failed");
      } else {
        transaction.update(docRef2, {
          "users": FieldValue.arrayRemove([_auth.currentUser!.uid]),
        });
        transaction.update(docRef, {
          "groups": FieldValue.arrayRemove([docRef2.id])
        });
        this.getSessions(special: true);
      }
      return 1;
    }).then((value) {
      return [1, "Left group"];
    }).catchError((e) {
      return [0, "An error occurred, check your internet connection"];
    }, test: (e) => e is PlatformException).catchError((e) {
      return [0, "${e.toString()}"];
    }, test: (e) => e is Exception);
  }

  Future deleteGroup(gid) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    DocumentReference docRef2 = _db.collection('groups').doc(gid);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot2 = await transaction.get(docRef2);
      GroupModel group = GroupModel.fromFirestore(
          snapshot2.data() as Map<String, dynamic>?, gid);
      if (!snapshot2.exists) {
        throw Exception("Failed");
      } else if (_auth.currentUser!.uid == group.creator) {
        throw Exception("Failed");
      } else {
        group.users.forEach((element) {
          _db
              .collection('users')
              .doc(element)
              .get()
              .then((value) => batch.update(value.reference, {
                    "groups": FieldValue.arrayRemove([gid]),
                  }));
        });
        batch.delete(docRef2);
        batch.commit();
        this.getSessions(special: true);
      }
      return 1;
    }).then((value) {
      return [1, "Left group"];
    }).catchError((e) {
      return [0, "An error occurred, check your internet connection"];
    }, test: (e) => e is PlatformException).catchError((e) {
      return [0, "${e.toString()}"];
    }, test: (e) => e is Exception);
  }
}
