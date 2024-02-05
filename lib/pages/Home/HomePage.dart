// ignore_for_file: unrelated_type_equality_checks

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tititata/button/bottomsheetbutton.dart';
import 'package:tititata/pages/ChatRoom/ChatRoomPage.dart';
import 'package:tititata/pages/Profile/ProfilePage.dart';
import 'package:tititata/pages/SearchUser/SearchUserPage.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var fetchuser = {};
  bool isLoading = false;

  fetchuserprofile() async {
    setState(() {
      isLoading = true;
    });

    var userdata = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {});
    fetchuser = userdata.data()!;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchuserprofile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchUserPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.search,
              size: 30,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      backgroundImage: NetworkImage(
                        fetchuser['userimg'],
                      ),
                    ),
                  ),
                ),
          const SizedBox(
            width: 10,
          ),
        ],
        title: Row(
          children: [
            Text(
              'TiTi',
              style: TextStyle(
                fontSize: 35,
                color: Colors.blue.shade500,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
              child: Text(
                'TaTa',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Text(
                      'Recent Chat',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.6),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('latest')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('user')
                          .orderBy('createAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'Chat not found',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.5),
                                  fontWeight: FontWeight.w700),
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                              child: GestureDetector(
                                onLongPress: () {
                                  showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    useSafeArea: true,
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        margin: const EdgeInsets.all(20),
                                        child: Wrap(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 30,
                                                      backgroundImage:
                                                          NetworkImage(
                                                        snapshot.data!
                                                                .docs[index]
                                                            ['userimg'],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      snapshot.data!.docs[index]
                                                          ['username'],
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    const Divider(
                                                      color: Colors.black,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            bottomsheetbutton(
                                              title: "Hide Chat",
                                              onTap: () async {
                                                Navigator.pop(context);
                                              },
                                              width: double.infinity,
                                              color: Colors.transparent,
                                            ),
                                            bottomsheetbutton(
                                              title: "Delete Chat",
                                              onTap: () async {
                                                Navigator.pop(context);
                                                FirebaseFirestore.instance
                                                    .collection('latest')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .collection('user')
                                                    .doc(snapshot.data!
                                                        .docs[index]['uid'])
                                                    .delete();
                                              },
                                              width: double.infinity,
                                              color: Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                        otheruid: snapshot.data!.docs[index]
                                            ['uid'],
                                        otherusername: snapshot
                                            .data!.docs[index]['username'],
                                        notitoken: snapshot.data!.docs[index]
                                            ['token'],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 220, 220, 220)
                                            .withOpacity(.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundImage: NetworkImage(
                                                snapshot.data!.docs[index]
                                                    ['userimg'],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  snapshot.data!.docs[index]
                                                      ['username'],
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${snapshot.data!.docs[index]['username']} Send ",
                                                      style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(.5),
                                                          fontSize: 14),
                                                    ),
                                                    Container(
                                                      width: 100,
                                                      child: Text(
                                                        snapshot.data!
                                                                .docs[index]
                                                            ['message'],
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(.8),
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          timeago.format(snapshot
                                              .data!.docs[index]['createAt']
                                              .toDate()),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(.5),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
