import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/AttendanceAuth.dart';
import 'package:digiatt_new/Screens/ClassScreens/AttendanceScreen.dart';
import 'package:digiatt_new/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../methods/CLassModel.dart';
import '../methods/UserModel.dart';

class TakeAttendance extends StatefulWidget {
  var classModel;
  UserModel userModel;

  TakeAttendance({Key? key, required this.classModel, required this.userModel}) : super(key: key);

  @override
  State<TakeAttendance> createState() => _TakeAttendanceState(classModel,userModel);
}

class _TakeAttendanceState extends State<TakeAttendance> {
  var classModel,userModel;

  final FormKey = GlobalKey<FormState>();

  // authenticate
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState __supportState = _SupportState.unknown;
  String authorized = 'Not Authorized';
  bool isAuthenticating = false;
  bool authenticated = false;


  final subLists = [];

  _TakeAttendanceState(this.classModel, this.userModel);



  DateTime Date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  var initialvalue;


  @override
  void initState() {
    super.initState();
      for(int i= 0; i<classModel['subjects'].length ; i++) {
        subLists.add(classModel['subjects'][i]);
      }


    auth.isDeviceSupported().then((bool isSupported) => setState(() => __supportState = isSupported ? _SupportState.supported : _SupportState.unsupported));
  }



  @override
  Widget build(BuildContext context) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    Size size = MediaQuery.of(context).size;
    bool isLoading = false;


    return Scaffold(
      appBar: AppBar(
        title: userModel.role == 'teacher' ?Text('Take Attendance') : Text('Give Attendance'),
      ),
      body: !isLoading ? Column(
        children: [
          SizedBox(height: size.height *0.05,),
          Form(
            key: FormKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
          ),
          SizedBox(height: size.height *0.05,),
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
          SizedBox(height: size.height *0.05,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Time : ${time.hour} : ${time.minute}",
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
          Text(''),
          SizedBox(height: size.height *0.1,),
          Container(
            child: __supportState == _SupportState.supported ? ElevatedButton(
                onPressed: () async {
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

                    var reference = await FirebaseFirestore.instance.collection('Classes').doc(classModel['id']).collection('Attendance').doc(attend_id);

                    if(userModel.role == 'teacher'){
                       try {
                         await reference.set(map);
                       } on FirebaseException catch (e) {
                         snackbarKey.currentState!.showSnackBar(SnackBar(content: Text(e.message!)));
                       }

                      Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceScreen(attend_data: map, userModel: userModel,ClassModel: classModel,)));
                    }else{
                      var snap = await reference.get();
                      if(snap.exists){

                        Future.delayed(const Duration(milliseconds: 2500), () async {
                          await authenticate();

                          if(authenticated){
                            reference.collection('List').doc(userModel.name).set(userModel.toJson()).then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendanceAuth())));
                          }



                        });

                        
                        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AttendanceScreen(attend_data: map, userModel: userModel, ClassModel: classModel)), (route) => false);
                      }else{
                        snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Attendance session not created')));
                      }
                    }


                  }
                },
                child: userModel.role == 'teacher'
                    ? Text('Take Attendance')
                    : Text('Give Attendance'))
            : Text('not supported'),
          ),
        ],
      ) : Center(child: CircularProgressIndicator(),),

    );
  }


Future authenticate() async {

  try{
    setState(() {
      isAuthenticating = true;
      authorized = 'Authenticating';
    });

    authenticated = await auth.authenticate(localizedReason: 'Verify fingerprint', options: AuthenticationOptions(stickyAuth: true, useErrorDialogs: true,biometricOnly: true));
  }on PlatformException catch (e) {
    print(e.message);
    setState(
            () {

          isAuthenticating = false;
          authorized = 'Error : ' + e.message!;
        }
    );
    return;
  }

  if(!mounted) {
    return;
  }

  setState(() {
    authorized = authenticated ? 'Authorized' : 'Not Authorized' ;
  });
}
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
