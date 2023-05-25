import 'dart:async';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/AttendanceResult.dart';
import 'package:digiatt_new/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendanceScreen extends StatefulWidget {
  var attend_data;
  var ClassModel;
  var userModel;
  AttendanceScreen({Key? key, required this.attend_data, required this.userModel,required this.ClassModel}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState(attend_data,userModel,ClassModel);
}

class _AttendanceScreenState extends State<AttendanceScreen> with WidgetsBindingObserver{
  var attend_data;
  var userModel, ClassModel;

  _AttendanceScreenState(this.attend_data, this.userModel,this.ClassModel);

  Timer? timer;
  static const maxSeconds = 30;
  int seconds = maxSeconds;
  BeaconBroadcast beaconBroadcast = BeaconBroadcast();
  final List<AppLifecycleState> _stateHistoryList = <AppLifecycleState>[];

  bool isAdvertising = false;



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopTimer();
    beaconBroadcast.stop().whenComplete(() {
      print('Beacon Stopped advertising');
    });
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused){
      timer?.cancel();
    }else if(state == AppLifecycleState.resumed){
      startTimer();
    }
    beaconBroadcast.stop();
    print(_stateHistoryList);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState != null) {
      _stateHistoryList.add(WidgetsBinding.instance.lifecycleState!);
    }
    // check the hardware for beacon support
    checkStatus();

    Permission.bluetoothAdvertise.request().then((status) async {
      if(status == PermissionStatus.granted){
        await beaconBroadcast
            .setUUID('24052023-2900-441A-802F-${attend_data['id']}')
            .setMajorId(1)
            .setMinorId(1).setIdentifier('com.beacon')
            .setTransmissionPower(44)
            .setAdvertiseMode(AdvertiseMode.balanced)
            .setLayout('m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24')
            .setManufacturerId(0x004c)
            .start();
      }else{
        snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('please grant BLE Permission')));
      }
    });
    // Timer Code
    startTimer();
      
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
                    ElevatedButton(onPressed: () async {
                      PermissionStatus isReady = await Permission.bluetoothAdvertise.status;
                      print(isReady.toString());
                        await Permission.bluetoothAdvertise.request();
                        isReady = await Permission.bluetoothAdvertise.status;
                        print(isReady.toString());
                      await beaconBroadcast
                          .setUUID('24052023-2900-441A-802F-${attend_data['id']}')
                          .setMajorId(1)
                          .setMinorId(100).setTransmissionPower(99)
                          .setLayout('m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24')
                          .setManufacturerId(0x004c)
                          .start();
                    }, child: Text('start beacon')),
                    ElevatedButton(onPressed: () => checkBeaconStatus(), child: Text('check')),
                    ElevatedButton(onPressed: () async {
                      await beaconBroadcast.stop().whenComplete(() {
                        checkBeaconStatus();
                        print('stopped advertising');});
                    }, child: Text('stop beacon')),
                    (isAdvertising) ? Text('true') : Text('false'),
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


  Future<void> checkStatus() async {
    BeaconStatus transmissionSupportStatus = await BeaconBroadcast().checkTransmissionSupported();
    switch (transmissionSupportStatus) {
      case BeaconStatus.supported:
        print("You're good to go, you can advertise as a beacon");
        setState(() {
          // isReady = true;
        });
        break;
      case BeaconStatus.notSupportedMinSdk:
        print("Your Android system version is too low (min. is 21)");
        break;
      case BeaconStatus.notSupportedBle:
        print('Your device doesnt support BLE');
        break;
      case BeaconStatus.notSupportedCannotGetAdvertiser:
        print('Either your chipset or driver is incompatible');
        break;
    }

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
                  onPressed: () async {
                    var reference = await FirebaseFirestore.instance.collection('Classes').doc(ClassModel['id']).collection('Attendance').doc(attend_data['id']);
                    await reference.delete();
                    Navigator.pop(context, true);

                  },
                  child: Text('Yes'))
            ],
          ));

  checkBeaconStatus() async {
    beaconBroadcast.isAdvertising().then((value) {
      if(value == true){
        setState(() {
          isAdvertising = true;
        });
      }else{
        setState(() {
          isAdvertising = false;
        });
      }
    });
  }

  startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if(seconds > 0){
        setState(() {
        seconds--;
      });
    }else{
    stopTimer();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendanceResult(attend_data: attend_data,classModel: ClassModel,)));
    }
    });
  }
  stopTimer() {
    timer?.cancel();
  }
}
