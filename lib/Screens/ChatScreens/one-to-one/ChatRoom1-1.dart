import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  var classData;
  var CUser;
  ChatRoom(
      {Key? key,
      required this.chatRoomId,
      required this.userMap,
      required this.classData,
      required this.CUser})
      : super(key: key);

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              foregroundImage: NetworkImage(userMap['photourl']),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              userMap['name'],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: ReadChats(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data?.docs[index]
                              .data() as Map<String, dynamic>;
                          return messages(size, map, context);
                        },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextFormField(
                      controller: _message,
                      decoration: InputDecoration(
                        hintText: 'Send Message',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.white)),
                        suffixIcon: IconButton(
                            onPressed: onSendMessage, icon: Icon(Icons.send)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return Container(
      width: size.width / 2,
      alignment: map['sendby'] == CUser.name
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        width: size.width / 1.5,
        child: map['sendby'] == CUser.name
            ? Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15),topLeft: Radius.circular(15))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(map['sendby'], style: TextStyle(color: Colors.purpleAccent,fontWeight: FontWeight.w700,fontSize: 16)),
                SizedBox(height: 5,),
                Text(
                  map['message'],
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          margin: EdgeInsets.symmetric(vertical: 2,horizontal: 5),
          color: Theme.of(context).colorScheme.primaryContainer,
        )
            : Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15),topRight: Radius.circular(15))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(map['sendby'], style: TextStyle(color: Colors.pinkAccent,fontWeight: FontWeight.w700,fontSize: 16)),
                SizedBox(height: 5,),
                Text(
                  map['message'],
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          margin: EdgeInsets.symmetric(vertical: 2,horizontal: 5),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ReadChats() {
    String classId = classData.id;

    return firestore
        .collection('Classes')
        .doc(classId)
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('chat')
        .orderBy('time', descending: false)
        .snapshots();
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      String classId = classData.id;

      Map<String, dynamic> messages = {
        'sendby': CUser.name,
        'message': _message.text,
        'time': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection('Classes')
          .doc(classId)
          .collection('ChatRooms')
          .doc(chatRoomId)
          .collection('chat')
          .add(messages);

      _message.clear();
    } else {}
  }
}
