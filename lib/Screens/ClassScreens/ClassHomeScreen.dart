import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../methods/CLassModel.dart';
import '../../methods/UserModel.dart';
import '../ChatScreens/GroupChatScreen.dart';
import 'BodyClassHomeScreen.dart';
import 'ClassAssignmentScreen.dart';
import 'ClassParticipantScreen.dart';
import 'ClassSettingsScreen.dart';

class ClassHomeScreen extends StatefulWidget {
  var classData;
  UserModel userModel;

  ClassHomeScreen({Key? key, required this.classData,required this.userModel}) : super(key: key);

  @override
  State<ClassHomeScreen> createState() => _ClassHomeScreenState(classData,userModel);
}

class _ClassHomeScreenState extends State<ClassHomeScreen> {
  var classData;
  var userModel;
  int index = 0;

  _ClassHomeScreenState(this.classData,this.userModel);

  var cUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(classData['name']),
          actions: [
            IconButton(onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => GroupChatScreen(classModel: classData, userModel: userModel,)));
            }, icon: Icon(Icons.messenger_rounded)),
            (userModel.role == 'teacher') ?
            IconButton(onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ClassSettingsScreen(classData: classData,userModel: userModel,)));
            }, icon: Icon(Icons.settings)) : Container()
          ],
        ),
        body: getPage(index),
        bottomNavigationBar: Container(
          color: Theme.of(context).colorScheme.primary,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: GNav(
              gap: 12,
              color: Colors.white,
              tabBackgroundColor: Colors.white,
              activeColor: Colors.black,
              padding: EdgeInsets.all(16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              selectedIndex: index,
              onTabChange: (index) => setState(() {
                this.index = index;
              }),
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.assignment,
                  text: 'Assignments',
                ),
                GButton(
                  icon: Icons.people_alt,
                  text: 'Participants',
                ),
              ],
            ),
          ),
        ));
  }

  Widget? getPage(int index) {
    switch (index) {
      case 0:
        {
          setState(() {
          });
          return BodyClassHomeScreen(
            classModel: classData,
          );
        }
        break;

      case 1:
        {setState(() {

        });
          return ClassAssignmentScreen(
            classModel: classData, userModel: userModel,
          );
        }
        break;
      case 2: {
        setState(() {

        });
        return ClassParticipantsScreen(
          classModel: classData,
        );
      }

        break;
    }
  }
}
