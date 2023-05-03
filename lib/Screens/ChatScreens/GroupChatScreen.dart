import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class GroupChatScreen extends StatefulWidget {
  var classModel, userModel;
  GroupChatScreen({Key? key, required this.classModel, required this.userModel})
      : super(key: key);

  @override
  State<GroupChatScreen> createState() =>
      _GroupChatScreenState(classModel, userModel);
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  var classModel, userModel;
  _GroupChatScreenState(this.classModel, this.userModel);

  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(classModel['name']),
      ),
      body: DisplayMessages(),
      bottomSheet: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextFormField(controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Send a message..',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 100),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: FloatingActionButton(
                  onPressed: () => createMessage(),
                  elevation: 0,
                  child: Icon(Icons.send),
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
    Widget DisplayMessages() {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Classes')
            .doc(classModel['id'])
            .collection('Chats')
            .orderBy("time")
            .snapshots(),
        builder: (context, snapshots) {
          return snapshots.connectionState == ConnectionState.waiting
              ? Container()
              : Container(
            height: MediaQuery.of(context).size.height /1.20,
                child: ListView.builder(itemCount: snapshots.data!.docs.length,
                itemBuilder: (context, index) {
                  var datetime = DateTime.fromMillisecondsSinceEpoch(snapshots.data!.docs[index]['time']);
                  return  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    alignment: snapshots.data!.docs[index]['sender'] == userModel.name
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width  / 1.5,
                      child: snapshots.data!.docs[index]['sender'] == userModel.name
                          ? Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10),topLeft: Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshots.data!.docs[index]['message'],
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              Align(alignment: Alignment.bottomRight,child: Text(datetime.hour.toString()+' : '+datetime.minute.toString(),style: TextStyle(fontSize: 11,color: Colors.white),)),
                            ],
                          ),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 2,horizontal: 5),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      )
                          : Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10),topRight: Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0,horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshots.data!.docs[index]['sender'].toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.amber),),
                              SizedBox(height: 5,),
                              Text(
                                snapshots.data!.docs[index]['message'],
                                style: TextStyle(fontSize: 15, color: Colors.white),
                              ),
                              Align(alignment: Alignment.bottomRight,child: Text(datetime.hour.toString()+' : '+datetime.minute.toString(),style: TextStyle(fontSize: 11,color: Colors.white),)),
                            ],
                          ),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 3,horizontal: 5),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  );
                }),
              );
        },
      );
    }


  Future createMessage() async {
    if(_messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message" : _messageController.text,
        "sender" : userModel.name,
        "time" : DateTime.now().millisecondsSinceEpoch
      };

      var docref = FirebaseFirestore.instance.collection('Classes').doc(classModel['id']).collection('Chats');

      await docref.add(chatMessageMap);
    }
  }
}
