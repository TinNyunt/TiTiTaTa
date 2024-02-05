// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final createAt = Timestamp.now();

  Future<void> SendMessage(
      String receiverId, String message, String token) async {
    final String currentUserId = auth.currentUser!.uid;
    final String currentUsername = auth.currentUser!.displayName.toString();

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String ChatRoomId = ids.join("_");

    await firestore
        .collection('ChatRoom')
        .doc(ChatRoomId)
        .collection('messages')
        .add({
      "senderId": currentUserId,
      "senderusername": currentUsername,
      "receiverId": receiverId,
      "message": message,
      "timestamp": createAt,
    });

    await firestore
        .collection('latest')
        .doc(receiverId)
        .collection('user')
        .doc(auth.currentUser!.uid)
        .set({
      "username": auth.currentUser!.displayName,
      'uid': currentUserId,
      'userimg': auth.currentUser!.photoURL,
      'message': message,
      "token": token,
      'createAt': createAt,
    });
  }

  Future<void> sendwithImage(
      String receiverId, String message, File msgimg) async {
    final String currentUserId = auth.currentUser!.uid;
    final String currentUsername = auth.currentUser!.displayName.toString();
    FirebaseStorage storage = FirebaseStorage.instance;

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String ChatRoomId = ids.join("_");

    var storageRef = storage.ref().child(
        'Wallpaper/${FirebaseAuth.instance.currentUser!.email}/${DateTime.now().toString()}');
    var uploadTask =
        storageRef.putFile(msgimg, SettableMetadata(contentType: 'image/png'));
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();

    await firestore
        .collection('ChatRoom')
        .doc(ChatRoomId)
        .collection('messages')
        .add({
      "senderId": currentUserId,
      "senderusername": currentUsername,
      "receiverId": receiverId,
      "timestamp": Timestamp.now(),
      'message': message,
      'img': downloadUrl,
    });

    await firestore
        .collection('latest')
        .doc(receiverId)
        .collection('user')
        .doc(auth.currentUser!.uid)
        .set({
      "username": auth.currentUser!.displayName,
      'uid': currentUserId,
      'userimg': auth.currentUser!.photoURL,
      'message': 'send image',
      'createAt': createAt,
    });
  }

  Stream<QuerySnapshot> getMessages(String userId, String otheruserId) {
    List<String> ids = [userId, otheruserId];
    ids.sort();
    String ChatRoomId = ids.join('_');

    return firestore
        .collection('ChatRoom')
        .doc(ChatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> DeleteMessage(String userId, String otheruserId, String id) {
    List<String> ids = [userId, otheruserId];
    ids.sort();
    String ChatRoomId = ids.join('_');

    return firestore
        .collection('ChatRoom')
        .doc(ChatRoomId)
        .collection('messages')
        .doc(id)
        .delete();
  }
}
