// ignore_for_file: must_be_immutable, unnecessary_cast

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tititata/button/bottomsheetbutton.dart';
import 'package:tititata/pages/ImageView/ImageView.dart';
import 'package:tititata/services/Chat.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:image_picker/image_picker.dart';
import 'package:tititata/services/notification.dart';

class ChatRoomPage extends StatefulWidget {
  String otheruid;
  String otherusername;
  String notitoken;

  ChatRoomPage({
    super.key,
    required this.otherusername,
    required this.otheruid,
    required this.notitoken,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController messageController = TextEditingController();
  final ChatService _service = ChatService();
  FirebaseAuth auth = FirebaseAuth.instance;
  late ScrollController listcontroller = ScrollController();
  File? msgimg;
  final picker = ImagePicker();
  bool msgdetails = false;
  var user = {};

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  void dispose() {
    listcontroller.dispose();
    super.dispose();
  }

  fetchUser() async {
    var userdata = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {});
    user = userdata.data()!;
  }

  void endtoscroll() {
    listcontroller.animateTo(
      listcontroller.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void sendmessage() async {
    if (messageController.text.isNotEmpty) {
      await _service.SendMessage(
        widget.otheruid,
        messageController.text,
        user['token'],
      );

      NotificationApi().sendNotification(
        FirebaseAuth.instance.currentUser!.displayName.toString(),
        messageController.text,
        widget.notitoken,
      );
      setState(() {
        msgimg = null;
      });
    }

    if (msgimg != null) {
      await _service.sendwithImage(
        widget.otheruid,
        messageController.text,
        msgimg!,
      );
      NotificationApi().sendNotification(
        FirebaseAuth.instance.currentUser!.displayName.toString(),
        "send image",
        widget.notitoken,
      );
      setState(() {
        msgimg = null;
      });
    }
    endtoscroll();
    messageController.clear();
  }

  void pickImage(context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Choose Photo',
                  style: TextStyle(fontSize: 26, color: Colors.black),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo,
                  color: Colors.black,
                ),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickfile =
                      await picker.pickImage(source: ImageSource.gallery);

                  setState(
                    () {
                      if (pickfile != null) {
                        msgimg = File(pickfile.path) as File?;
                      } else {
                        print("Select User Image");
                      }
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera,
                  color: Colors.black,
                ),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickfile =
                      await picker.pickImage(source: ImageSource.camera);

                  setState(
                    () {
                      if (pickfile != null) {
                        msgimg = File(pickfile.path) as File?;
                      } else {
                        print("Select User Image");
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(milliseconds: 400),
      () => listcontroller.jumpTo(
        listcontroller.position.maxScrollExtent,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.otherusername,
          style: const TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.w400),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _service.getMessages(
                    widget.otheruid, FirebaseAuth.instance.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView(
                    controller: listcontroller,
                    physics: const BouncingScrollPhysics(),
                    children: snapshot.data!.docs
                        .map((doc) => getAllMessage(doc))
                        .toList(),
                  );
                },
              ),
            ),
            Column(
              children: [
                msgimg != null
                    ? GestureDetector(
                        onTap: () {},
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Stack(
                            children: [
                              Image.file(
                                msgimg!,
                                fit: BoxFit.cover,
                                height: 150,
                              ),
                              Positioned(
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      msgimg = null;
                                    });
                                  },
                                  child: const Icon(Icons.close),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
                Row(
                  children: [
                    IconButton(
                      splashRadius: 20,
                      onPressed: () => pickImage(context),
                      icon: const Icon(Icons.photo),
                    ),
                    Expanded(
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: TextFormField(
                            enabled: msgimg != null ? false : true,
                            controller: messageController,
                            style: const TextStyle(fontSize: 20),
                            decoration: const InputDecoration.collapsed(
                              hintText: "send something...",
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: sendmessage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.1),
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(13.0),
                          child: Icon(
                            Icons.send,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  messageDetails(doc) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          margin: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                child: Text(
                  'Message',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              const Divider(
                color: Colors.black,
              ),
              FirebaseAuth.instance.currentUser!.uid != doc.data()['receiverId']
                  ? bottomsheetbutton(
                      title: "Remove Message",
                      onTap: () {
                        Navigator.pop(context);
                        _service.DeleteMessage(
                          widget.otheruid,
                          FirebaseAuth.instance.currentUser!.uid,
                          doc.id,
                        );
                      },
                      width: double.infinity,
                      color: Colors.transparent,
                    )
                  : const SizedBox(),
              bottomsheetbutton(
                title: "Details Message",
                onTap: () {
                  setState(() {
                    msgdetails = !msgdetails;
                  });
                },
                width: double.infinity,
                color: Colors.transparent,
              )
            ],
          ),
        );
      },
    );
  }

  Widget getAllMessage(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final same = data['senderId'] == FirebaseAuth.instance.currentUser!.uid;

    return Container(
      alignment: same ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment:
              same ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment:
              same ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () => messageDetails(document),
              child: Container(
                width: data['message'].toString().length < 55 ? null : 300,
                decoration: BoxDecoration(
                  color: same ? Colors.blue : Colors.grey,
                  borderRadius: same
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: same
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      data['img'] == null
                          ? const SizedBox()
                          : GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageView(
                                    img: data['img'],
                                  ),
                                ),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: data['img'],
                                imageBuilder: (context, imageProvioder) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image(
                                      width: 190,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      image: imageProvioder,
                                    ),
                                  );
                                },
                                placeholder: (context, url) => const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                      data['message'].toString().isNotEmpty
                          ? Text(
                              data['message'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
            msgdetails
                ? Text(
                    timeago.format(data['timestamp'].toDate()),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
