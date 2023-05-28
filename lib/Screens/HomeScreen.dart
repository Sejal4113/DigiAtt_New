import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/ProfileScreen.dart';
import 'package:digiatt_new/methods/UserModel.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'ClassScreens/ClassHomeScreen.dart';
import 'CreateGroup.dart';
import 'JoinClass.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var user = FirebaseAuth.instance.currentUser!;

  var snap;
  var classlists = [];
  var _code = TextEditingController();
  var userdata;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DigiAtt'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.person), onPressed: () { Navigator.push(context, CupertinoPageRoute(builder: (context) => ProfileScreen())); },)
        ],
      ),
      floatingActionButton: FutureBuilder<UserModel?>(
        future: ReadUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            snackbarKey.currentState
                ?.showSnackBar(SnackBar(content: Text('Something went wrong')));
          } else if (snapshot.hasData) {
            var user1 = snapshot.data;
            userdata = user1;

            return user1 == null
                ? const Center(
                    child: Text('No user'),
                  )
                : FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      if (userdata.role == 'teacher') {
                        ShowModalTeacher();
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => JoinClass()));
                      }
                    },
                    child: Icon(Icons.add),
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
      body: RefreshIndicator(
        onRefresh: () {
          return FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get()
              .then((value) => classlists = value.data()!['inGroup']);
        },
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get()
              .then((value) => classlists = value.data()!['inGroup']),
          builder: (context, snap) {
            return snap.connectionState == ConnectionState.waiting
                ? Container()
                : (snap.data.length == 0) ? Center(child: Text("No classes Joined \n  Press the '+' Icon to Get started",textAlign: TextAlign.center,style: TextStyle(fontSize: 17),),):ListView.separated(
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('Classes')
                              .doc(snap.data[index])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var data = snapshot.data!.data()!;
                              return ListTile(
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ClassHomeScreen(
                                            classData: data,
                                            userModel: userdata))),
                                title: Text(data['name']),
                                subtitle: Text(data['description']),
                                leading: data['photourl'] == ''
                                    ? CircleAvatar(backgroundColor: Colors.grey.withOpacity(0.5),child: Icon(Icons.group, color: Colors.grey.shade700),)
                                    : CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(data['photourl']),
                                      ),
                              );
                            } else {
                              return Container();
                            }
                          });
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: snap.data.length);
          },
        ),
      ),

      // body: Stack(
      //   children: [
      //     Container(
      //       color: Colors.grey.shade100,
      //     ),
      //     FutureBuilder(
      //       future: readClass(),
      //       builder: (context, snapshot) {
      //         if (snapshot.connectionState == ConnectionState.waiting) {
      //           return Container();
      //         } else if (snapshot.hasError) {
      //           return Container(
      //             child: Center(
      //               child: Text('Something went wrong'),
      //             ),
      //           );
      //         } else if (snapshot.hasData) {
      //           final users = snapshot.data!;
      //
      //           return Text(classlists[0]['photourl']);
      //
      //           // return ListView.separated(itemBuilder: (context, index) {
      //           //   return ListTile(
      //           //     leading: (classlists[index]['photourl'] == '') ? CircleAvatar(
      //           //       backgroundColor:  Colors.grey.withOpacity(0.5),
      //           //       child: Icon(Icons.person),
      //           //     ): CircleAvatar(
      //           //       backgroundImage: NetworkImage(classlists[index]['photourl']),
      //           //     )
      //           //   );
      //           // }, separatorBuilder: (context,index) {
      //           //   return Divider();
      //           //
      //           // }, itemCount: classlists.length);
      //         } else {
      //           return Center(child: CircularProgressIndicator());
      //         }
      //       },
      //     ),
      //   ],
      // ),
    );
  }

  Future<UserModel?> ReadUser() async {
    final Docid = FirebaseFirestore.instance.collection("Users").doc(user.uid);
    final snapshot = await Docid.get();

    if (snapshot.exists) {
      return UserModel.fromJson(snapshot.data()!);
    }
  }

  Future ShowModalTeacher() {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        builder: (context) {
          return Container(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select an Option',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => JoinClass()));
                              },
                              child: Text('Join a Class'))),
                    ],
                  ),
                  Text(
                    'OR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => CreateGroup()));
                              },
                              child: Text('Create a Class'))),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
