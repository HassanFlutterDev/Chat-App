import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final email;
  final String uid;
  final photoUrl;
  final friends;
  final requests;
  final username;
  final searchIndex;
  final String bio;
  final String status;
  final String typing;
  final DateTime statusT;
  final String verify;
  final String token;
  final bool call;
  final String callId;
  final String callUid;
  final bool callAccept;

  const User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.call,
    required this.email,
    required this.bio,
    required this.callAccept,
    required this.callUid,
    required this.friends,
    required this.requests,
    required this.searchIndex,
    required this.callId,
    required this.verify,
    required this.token,
    required this.typing,
    required this.statusT,
    required this.status,
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      bio: snapshot["bio"],
      verify: snapshot["verify"],
      status: snapshot["status"],
      typing: snapshot["typing"],
      statusT: snapshot["statusT"],
      token: snapshot["token"],
      requests: snapshot["requests"],
      call: snapshot["call"],
      friends: snapshot["friends"],
      callId: snapshot["callId"],
      callAccept: snapshot["callAccept"],
      callUid: snapshot["callUid"],
      searchIndex: snapshot["searchIndex"],
      photoUrl: snapshot["photoUrl"],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "searchIndex": searchIndex,
        "email": email,
        "friends": friends,
        "request": requests,
        "callId": callId,
        "bio": bio,
        "token": token,
        "callUid": callUid,
        "callAccept": callAccept,
        "verify": verify,
        "status": status,
        "typing": typing,
        "statusT": statusT,
        "photoUrl": photoUrl,
        "call": call,
      };
}
