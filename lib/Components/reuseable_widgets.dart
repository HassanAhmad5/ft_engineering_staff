import 'package:flutter/material.dart';


class ReuseableButton extends StatelessWidget {
  String text;
  final Function() onPressed;
  ReuseableButton({super.key, required this.text, required this.onPressed});


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow.shade200,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ],
        )
    );
  }
}
