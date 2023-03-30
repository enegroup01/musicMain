import 'package:flutter/material.dart';

class FeelingTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.green],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(
              Icons.monitor_heart_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          border: InputBorder.none,
          hintText: "I'm feeling like...",
          hintStyle: TextStyle(color: Colors.white),
        ),
        onFieldSubmitted: (value) {
          print(value);
        },
      ),
    );
  }
}
