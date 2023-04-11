import 'dart:async';

import 'package:digiatt_new/Screens/AttendanceResult.dart';
import 'package:digiatt_new/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AttendanceScreen extends StatefulWidget {
  var attend_data;
  var ClassModel;
  var userModel;
  AttendanceScreen({Key? key, required this.attend_data, required this.userModel,required this.ClassModel}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState(attend_data,userModel,ClassModel);
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  var attend_data;
  var userModel, ClassModel;

  _AttendanceScreenState(this.attend_data, this.userModel,this.ClassModel);

  Timer? timer;
  static const maxSeconds = 30;
  int seconds = maxSeconds;


  @override
  void dispose() {

    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if(seconds > 0){
        setState(() {
          seconds--;
        });
      }else{
        timer?.cancel();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendanceResult(attend_data: attend_data,classModel: ClassModel,)));
      }

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await ShowMyDialog();
        return shouldPop ?? false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Attendance Screen'),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance Details',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                    SizedBox(height: size.height*0.02,),
                    Text(
                      'Subject : ${attend_data['subject']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(
                      'Date : ${attend_data['date']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(
                      "Time : ${attend_data['time']}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),

                Text(
                  seconds.toString(),
                  style: TextStyle(fontSize: 40),
                ),

                Container(margin: EdgeInsets.all(20),child: Text('Ask your students to mark their attendance on the app. share the attendance details with the students'))
              ],
            ),
          )),
    );
  }

  Future<bool?> ShowMyDialog() => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Do you really want to exit?'),
            content: Text('You will lose all attendance data if you leave.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes'))
            ],
          ));
}
