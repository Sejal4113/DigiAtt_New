import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/ChatScreens/one-to-one/ChatRoom1-1.dart';
import 'package:digiatt_new/main.dart';
import 'package:digiatt_new/methods/CLassModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../methods/UserModel.dart';

class SearchUserScreen extends StatefulWidget {
  var classData;
  UserModel userModel;
  SearchUserScreen({Key? key, required this.classData,required this.userModel}) : super(key: key);

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState(classData,userModel);
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  var classData,CuuserModel;
  _SearchUserScreenState(this.classData,this.CuuserModel);

  FirebaseAuth _user = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = '';
//TODO check if updatedisplayname is working and change all currentuser models into user.displayname form
  String chatRoomId(String user1,String user2) {
    if (user1[0].toLowerCase().codeUnits[0] > user2[0].toLowerCase().codeUnits[0]) {
      return '$user1$user2';
    }else{
      return '$user2$user1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Card(
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search), hintText: 'Search...',),
                  onChanged: (val) {
                    setState(() {
                      name = val;
                    });
                  },
                ),

              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Classes')
            .doc(classData['id'])
            .collection('members')
            .snapshots(),
        builder: (context, snapshots) {
          return (snapshots.connectionState == ConnectionState.waiting)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: snapshots.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshots.data!.docs[index].data()
                        as Map<String, dynamic>;

                    if (name.isEmpty) {
                      return ListTile(
                          onTap: () {

                            String roomId = chatRoomId(CuuserModel.name, data['name']);

                            data['id'] = roomId;

                            firestore.collection('Classes').doc(classData['id']).collection('ChatRooms').doc(roomId).set(data).then((value) {Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(chatRoomId: roomId, userMap: data, classData: classData, CUser: CuuserModel,)));});


                          },
                        title: Text(data['name']),
                        subtitle: Text(data['email']),
                        leading: data['photourl'] != '' ? CircleAvatar(
                          backgroundImage: NetworkImage(data['photourl'])
                        ) : CircleAvatar(
                          backgroundColor: Colors.grey.withOpacity(0.5),
                          child: Icon(
                            Icons.group,
                            color: Colors.grey.shade700,
                          ),
                        )
                      );
                    }

                    if(data['name'].toString().toLowerCase().startsWith(name.toLowerCase())) {
                      return ListTile(
                          onTap: () {

                            String roomId = chatRoomId(CuuserModel.name, data['id']);

                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(chatRoomId: roomId, userMap: data, classData: classData, CUser: CuuserModel,)));
                          },
                        title: Text(data['name']),
                        subtitle: Text(data['email']),
                          leading: data['photourl'] != '' ? CircleAvatar(
                              backgroundImage: NetworkImage(data['photourl'])
                          ) : CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.5),
                            child: Icon(
                              Icons.group,
                              color: Colors.grey.shade700,
                            ),
                          )
                      );
                    }
                    return Container();
                  });
        },
      ),
    );
  }
}
