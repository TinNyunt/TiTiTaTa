// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  String img;
  ImageView({super.key, required this.img});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final imagePath = '${Directory.systemTemp.path}/image.jpg';
              await Dio().download(img, imagePath);
              await Gal.putImage(imagePath);
              Fluttertoast.showToast(
                msg: "Save to gallery",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            icon: const Icon(
              Icons.download,
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: PhotoView(
          imageProvider: NetworkImage(img),
        ),
      ),
    );
  }
}
