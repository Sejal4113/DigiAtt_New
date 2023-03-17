import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/ChatScreens/SearchUserScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../methods/CLassModel.dart';
import '../../methods/UserModel.dart';

class ChatHomeScreen extends StatefulWidget {
  ClassModel classData;
  ChatHomeScreen({Key? key,required this.classData}) : super(key: key);

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState(classData);
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  var classData;
  _ChatHomeScreenState(this.classData);

  var user = FirebaseAuth.instance.currentUser!;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var usermodel;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: FutureBuilder<UserModel?>(
        future: ReadUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            snackbarKey.currentState
                ?.showSnackBar(SnackBar(content: Text('Something went wrong')));
          } else if (snapshot.hasData) {
            usermodel = snapshot.data;

            return usermodel == null
                ? Center(
              child: Text('No user'),
            )
                : SingleChildScrollView(
              child: Text(usermodel.name)
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchUserScreen(classData: classData, userModel: usermodel,)));
        },
        child: Icon(Icons.message_sharp),
        backgroundColor: Theme.of(context).colorScheme.primary,
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

