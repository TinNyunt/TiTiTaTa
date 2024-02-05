import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../button/mybutton.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var user = {};
  bool isLoading = false;

  fetchUser() async {
    setState(() {
      isLoading = true;
    });

    var userdata = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {});
    user = userdata.data()!;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 25),
        ),
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: user['userimg'],
                      imageBuilder: (context, imageProvioder) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: imageProvioder,
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      user['username'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      user['email'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(.5),
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyButton(
                          title: "Logout",
                          onTap: () {
                            FirebaseAuth.instance.signOut();
                            GoogleSignIn().signOut();
                            Navigator.pop(context);
                          },
                          width: 150,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        MyButton(
                          title: "Delete Account",
                          onTap: () {
                            FirebaseAuth.instance.currentUser!.delete();
                            FirebaseFirestore.instance
                                .collection('user')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .delete();
                            Navigator.pop(context);
                          },
                          width: 150,
                          color: Colors.blue,
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
