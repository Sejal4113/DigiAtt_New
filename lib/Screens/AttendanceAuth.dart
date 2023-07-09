import 'package:digiatt_new/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';

import '../methods/ad_mob_service.dart';

class AttendanceAuth extends StatefulWidget {
  const AttendanceAuth({Key? key}) : super(key: key);

  @override
  State<AttendanceAuth> createState() => _AttendanceAuthState();
}

class _AttendanceAuthState extends State<AttendanceAuth> {

  BannerAd? _banner;

  @override
  void initState() {
    _createBannerAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
      Container(
        decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50),bottomRight: Radius.circular(50))
        ),
        height: size.height / 2 ,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 150,
                child: Lottie.asset(
                  'lib/assets/images/check.json',
                  repeat: false,
                ),
              ),
              SizedBox(height: 20,),
              Text(
                'Attendance Marked!!',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),
              ),
            ],
          ),
        ),
      ),
      Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Go back')),
            ),
          ),
        ],
      )
        ],
      ),
      bottomNavigationBar: _banner == null ? Container() : Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 12),
        height: 52,
        child: AdWidget(ad: _banner!),
      ),
    );
  }

  void _createBannerAd() {
    _banner = BannerAd(size: AdSize.fullBanner, adUnitId: AdMobService.bannerAdUnitId!, listener: AdMobService.bannerListener, request: const AdRequest())..load();
  }
}
