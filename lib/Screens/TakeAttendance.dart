import 'package:digiatt_new/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../methods/CLassModel.dart';
import '../methods/UserModel.dart';

class TakeAttendance extends StatefulWidget {
  ClassModel classModel;
  UserModel userModel;

  TakeAttendance({Key? key, required this.classModel, required this.userModel}) : super(key: key);

  @override
  State<TakeAttendance> createState() => _TakeAttendanceState(classModel,userModel);
}

class _TakeAttendanceState extends State<TakeAttendance> {
  var classModel,userModel;

  final FormKey = GlobalKey<FormState>();
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState __supportState = _SupportState.unknown;
  String authorized = 'Not Authorized';
  bool isAuthenticating = false;


  final subLists = [
    'Computer Graphics',
    'Analysis of Algorithm',
    'Maths',
    'Operating Systems',
    'Microprocessor',
    'Python'
  ];

  _TakeAttendanceState(this.classModel, this.userModel);



  DateTime Date = DateTime.now();
  TimeOfDay time = TimeOfDay(hour: 10, minute: 30);
  var initialvalue;


  @override
  void initState() {
    super.initState();

    auth.isDeviceSupported().then((bool isSupported) => setState(() => __supportState = isSupported ? _SupportState.supported : _SupportState.unsupported));
  }

  @override
  Widget build(BuildContext context) {

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    Size size = MediaQuery.of(context).size;


    return Scaffold(
      appBar: AppBar(
        title: Text('Take Attendance'),
      ),
      body: Column(
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
          Container(
            child: __supportState == _SupportState.supported ? ElevatedButton(
                onPressed: () {
                  if(FormKey.currentState!.validate()){
                    //snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Works')));
                    authenticate();
                  }
                },
                child: userModel.role == 'teacher'
                    ? Text('Take Attendance')
                    : Text('Give Attendance'))
            : Text('not supported'),
          )
        ],
      ),

    );
  }


void authenticate() async {
  bool authenticated = false;

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
