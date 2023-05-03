import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/ChatScreens/SearchUserScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../methods/CLassModel.dart';
import '../../methods/UserModel.dart';
import 'one-to-one/ChatRoom1-1.dart';

class ChatHomeScreen extends StatefulWidget {
  var classData;
  UserModel userdata;
  ChatHomeScreen({Key? key, required this.classData, required this.userdata})
      : super(key: key);

  @override
  State<ChatHomeScreen> createState() =>
      _ChatHomeScreenState(classData, userdata);
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  var classData;
  var userdata;
  _ChatHomeScreenState(this.classData, this.userdata);

  var user = FirebaseAuth.instance.currentUser!;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Classes')
              .doc(classData['id'])
              .collection('ChatRooms')
              .snapshots(),
          builder: (context, snapshot) {
            return (snapshot.connectionState == ConnectionState.waiting)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                      if (data['id'].toString().contains(userdata.name)) {
                        return ListTile(
                          onTap: () {
                            // snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('works')));
                            var roomId = data['id'];
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(chatRoomId: roomId, userMap: data, classData: classData, CUser: userdata,)));
                          },
                          leading: (data['photourl'] == '') ? CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.5),
                            child: Icon(
                              Icons.group,
                              color: Colors.grey.shade700,
                            ),
                          ) :  CircleAvatar(
                            backgroundImage: NetworkImage(data['photourl']),
                          ),
                          subtitle: Text(data['email']),
                          title: (data['name'] == userdata.name) ?Text(data['name']+' (You)', style: TextStyle(fontWeight: FontWeight.bold),) : Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold),),
                        );
                      }
                    });
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchUserScreen(
                    classData: classData,
                    userModel: userdata,
                  )));
        },
        child: Icon(Icons.message_sharp),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget buildUser(Map<String, dynamic> messageTile) {
    return ListTile(
      title: Text(messageTile['name']),
    );
  }
}
