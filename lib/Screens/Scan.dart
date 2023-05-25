import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:permission_handler/permission_handler.dart';

class Scan extends StatefulWidget {
  const Scan({Key? key}) : super(key: key);

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {

  final regions = <Region>[];
  late StreamSubscription _streamRanging;


  @override
  void initState() {
    Permission.bluetoothConnect.request().then((value) {
      if(value.isGranted){
        flutterBeacon.initializeAndCheckScanning;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('scan'),
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: () async {

            await Permission.bluetoothScan.request();
            PermissionStatus status = await Permission.bluetoothConnect.status;
            if(status.isGranted) {
              try {
                // if you want to include automatic checking permission
                await flutterBeacon.initializeAndCheckScanning;

                PermissionStatus statusScan = await Permission.bluetoothScan.status;
                if(statusScan.isGranted) {
                  if (Platform.isIOS) {
                    // iOS platform, at least set identifier and proximityUUID for region scanning
                    regions.add(Region(
                        identifier: 'Apple Airlocate',
                        proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
                  } else {
                    // android platform, it can ranging out of beacon that filter all of Proximity UUID
                    regions.add(Region(identifier: 'com.beacon'));
                  }

                  // to start ranging beacons
                  _streamRanging = flutterBeacon.ranging(regions).listen((
                      RangingResult result) {
                    result.beacons.forEach((element) {

                    });
                  });
                }

              } on PlatformException catch (e) {
                // library failed to initialize, check code and message
                print(e.message);
              }
            }else{
              print('Permission failed');
            }
          }, child: Text('Scan')),
          ElevatedButton(onPressed: () async {
            // to stop ranging beacons
            await _streamRanging.cancel();
          }, child: Text('Stop'))
        ],
      ),
    );
  }
}

