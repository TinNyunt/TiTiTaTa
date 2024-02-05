// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class bottomsheetbutton extends StatelessWidget {
  String title;
  VoidCallback onTap;
  Color color;
  double width;

  bottomsheetbutton({
    super.key,
    required this.title,
    required this.onTap,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: width,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
