import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tititata/pages/ChatRoom/ChatRoomPage.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController searchController = TextEditingController();
  bool isShowPost = false;
  bool isLoading = false;
  List result = [];
  List getResult = [];

  @override
  void initState() {
    super.initState();
    getSearchFetch();
    searchController.addListener(_onsearch);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.removeListener(_onsearch);
    searchController.dispose();
  }

  _onsearch() {
    setState(() {
      isLoading = true;
    });
    var showResult = [];
    if (searchController.text != '') {
      for (var snap in result) {
        var name = snap['username'].toString().toLowerCase();
        if (name.contains(searchController.text.toLowerCase())) {
          showResult.add(snap);
        }
      }
    }
    setState(() {
      isLoading = false;
      getResult = showResult;
      isShowPost = true;
    });
  }

  getSearchFetch() async {
    setState(() {
      isLoading = true;
    });
    var data = await FirebaseFirestore.instance
        .collection('user')
        .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      isLoading = false;
      result = data.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      )),
                  const Text(
                    "For Chat",
                    style: TextStyle(color: Colors.blue, fontSize: 28),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: searchController,
                  autofocus: false,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  decoration: InputDecoration(
                    isDense: true,
                    suffixIconColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    suffixIcon: const Icon(
                      Icons.search,
                      size: 30,
                    ),
                    hintText: "Search..",
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Search Result

              isLoading
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : isShowPost
                      ? getResult.isEmpty
                          ? Expanded(
                              child: Center(
                                child: Text(
                                  'Searching!',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.5),
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: getResult.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatRoomPage(
                                            otheruid: getResult[index]['uid'],
                                            otherusername: getResult[index]
                                                ['username'],
                                            notitoken: getResult[index]
                                                ['token'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            95, 162, 158, 158),
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(.5),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl: getResult[index]
                                                      ['userimg'],
                                                  imageBuilder: (context,
                                                      imageProvioder) {
                                                    return ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      child: Image(
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.fill,
                                                        image: imageProvioder,
                                                      ),
                                                    );
                                                  },
                                                  placeholder: (context, url) =>
                                                      const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      getResult[index]
                                                          ['username'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 23,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      getResult[index]['email'],
                                                      style: const TextStyle(
                                                        color: Color.fromARGB(
                                                            132, 255, 255, 255),
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const Icon(
                                              Icons.message_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                      : Expanded(
                          child: Center(
                            child: Text(
                              'User chat',
                              style: TextStyle(
                                color: Colors.white.withOpacity(.5),
                                fontWeight: FontWeight.w700,
                              ),
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
