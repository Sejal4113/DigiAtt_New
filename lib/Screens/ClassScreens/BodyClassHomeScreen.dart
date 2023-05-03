import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/AttendanceResult.dart';
import 'package:digiatt_new/Screens/TakeAttendance.dart';
import 'package:digiatt_new/main.dart';
import 'package:digiatt_new/methods/CLassModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../../methods/UserModel.dart';

class BodyClassHomeScreen extends StatefulWidget {
  var classModel;

  BodyClassHomeScreen({Key? key, required this.classModel}) : super(key: key);

  @override
  State<BodyClassHomeScreen> createState() =>
      _BodyClassHomeScreenState(classModel);
}

class _BodyClassHomeScreenState extends State<BodyClassHomeScreen> {
  var classModel;
  var user = FirebaseAuth.instance.currentUser!;
  final FormKey = GlobalKey<FormState>();

  final subLists = [];
  DateTime Date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  var initialvalue;

  _BodyClassHomeScreenState(this.classModel);


  @override
  void initState() {
    for(int i= 0; i<classModel['subjects'].length ; i++) {
      subLists.add(classModel['subjects'][i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: ReadUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            snackbarKey.currentState
                ?.showSnackBar(SnackBar(content: Text('Something went wrong')));
          } else if (snapshot.hasData) {
            var usermodel = snapshot.data;

            return usermodel == null
                ? Center(
              child: Text('No user'),
                )
                : Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height*0.01,),
                    Text('Download Attendance data',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
                    new Divider(thickness: 2,),
                    SizedBox(height: size.height *0.03,),
                    Form(
                      key: FormKey,
                      child: DropdownButtonFormField(
                        validator: (value) => (value == null) ? 'Please Select Subject' : null,
                        hint: Text('Select Subjects'),
                        isExpanded: true,
                        value: initialvalue,
                        items: subLists
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            initialvalue = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: size.height *0.02,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Date : ${Date.day}/${Date.month}/${Date.year}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(),
                        IconButton(
                          onPressed: () async {
                            DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: Date,
                              firstDate: DateTime(1999),
                              lastDate: DateTime(2300),
                            );

                            if (newDate == null) return;

                            setState(() {
                              Date = newDate;
                            });
                          },
                          icon: Icon(Icons.date_range_rounded),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height *0.02,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Time : ${hour} : ${minute}",
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          height: 1,
                        ),
                        IconButton(
                          onPressed: () async {
                            TimeOfDay? newTime = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );
                            if (newTime == null) return;

                            setState(() {
                              time = newTime;
                            });
                          },
                          icon: Icon(Icons.access_time),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height *0.1,),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(8),
                              child:ElevatedButton(onPressed: () async {
                              if(FormKey.currentState!.validate()){
                                String date = "${Date.day}/${Date.month}/${Date.year}";
                                String time1 = "${time.hour} : ${time.minute}";
                                String attend_id = initialvalue+'-'+Date.day.toString()+'-'+Date.month.toString()+'-'+Date.year.toString()+'-'+time.hour.toString()+'-'+time.minute.toString();
                                var map = {
                                  'subject' : initialvalue,
                                  'date' : date,
                                  'time' : time1,
                                  'id' : attend_id
                                };
                                var reference = await FirebaseFirestore.instance.collection('Classes').doc(classModel['id']).collection('Attendance').doc(attend_id).get();
                                 if(reference.exists) {
                                   Navigator.of(context).push(MaterialPageRoute(builder: (context) => AttendanceResult(attend_data: map, classModel: classModel,)));
                                 }else{
                                   snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Attendance record not found')));
                                 }
                                // snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('works')));
                              }
                                  }, child: Text('Download record'))),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(8),
                            child:ElevatedButton(
                                  onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => TakeAttendance(classModel: classModel, userModel: usermodel)));

                                  },
                                  child: usermodel.role == 'teacher'
                                      ? Text('Take Attendance')
                                      : Text('Give Attendance')),
                            ),
                        ),
                      ],
                    )

                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<UserModel?> ReadUser() async {
    final Docid = FirebaseFirestore.instance.collection("Users").doc(user.uid);
    final snapshot = await Docid.get();

    if (snapshot.exists) {
      return UserModel.fromJson(snapshot.data()!);
    }
  }
}
