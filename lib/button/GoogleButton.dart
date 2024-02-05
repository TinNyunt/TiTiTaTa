// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  String title;
  VoidCallback onTap;
  Color color;
  double width;

  GoogleButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  const Image(
                    width: 30,
                    height: 30,
                    fit: BoxFit.fill,
                    image: AssetImage('images/google.png'),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
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
