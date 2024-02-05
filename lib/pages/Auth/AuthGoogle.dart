// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../button/GoogleButton.dart';

class GoogleAuthPage extends StatefulWidget {
  const GoogleAuthPage({super.key});

  @override
  State<GoogleAuthPage> createState() => _GoogleAuthPageState();
}

class _GoogleAuthPageState extends State<GoogleAuthPage> {
  final notifications = FirebaseMessaging.instance;

  LoginAccount() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final token = await notifications.getToken();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential result =
        await FirebaseAuth.instance.signInWithCredential(credential);

    FirebaseFirestore.instance.collection('user').doc(result.user?.uid).set({
      "username": result.user!.displayName,
      "userimg": result.user!.photoURL,
      "uid": result.user!.uid,
      "email": result.user!.email,
      "token": token,
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/Background.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Easy Chat With Friends',
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'TiTiTaTa Chat App',
                  style: TextStyle(
                    fontSize: 25,
                    color: const Color.fromARGB(255, 69, 69, 69),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 80,
            ),
            GoogleButton(
              title: "Google with signin",
              onTap: LoginAccount,
              width: 350,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }
}
