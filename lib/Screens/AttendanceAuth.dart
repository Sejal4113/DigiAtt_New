import 'package:digiatt_new/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';

class AttendanceAuth extends StatefulWidget {
  const AttendanceAuth({Key? key}) : super(key: key);

  @override
  State<AttendanceAuth> createState() => _AttendanceAuthState();
}

class _AttendanceAuthState extends State<AttendanceAuth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Attendance Marked!!', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 37),),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(40),
                  child: ElevatedButton(onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  }, child: Text('Go back')),
                ),
              ),
            ],
          )
        ],
      )),
    );
  }
}
