
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  ScrollController _controller = ScrollController();

  Stream? prStream;

  @override
  void initState() {
    prStream = FirebaseFirestore.instance
        .collection('Classes')
        .doc(classModel['id'])
        .collection('Chats')
        .orderBy("time")
        .snapshots();

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(classModel['name']),
      ),
      body: DisplayMessages(),
    );
  }

  Widget DisplayMessages() {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: StreamBuilder(
        stream: prStream,
        builder: (context, snapshots) {
          return snapshots.connectionState == ConnectionState.waiting
              ? Container()
              : SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height /
                                1.23, //Display the height of message screen
                            child: ListView.builder(
                                controller: _controller,
                                itemCount: snapshots.data!.docs.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  var datetime =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          snapshots.data!.docs[index]['time']);
                                  return (index >= 1 &&
                                          datetime.day ==
                                              DateTime.fromMillisecondsSinceEpoch(
                                                      snapshots.data!
                                                              .docs[index - 1]
                                                          ['time'])
                                                  .day)
                                      ? Container(
                                          alignment: snapshots.data!.docs[index]
                                                      ['sender'] ==
                                                  userModel.name
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.4,
                                            child: snapshots.data!.docs[index]
                                                        ['sender'] ==
                                                    userModel.name
                                                ? Card(
                                                    elevation: 5,
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft:
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10))),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 2,
                                                            horizontal: 5),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 16.0,
                                                          horizontal: 20.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              snapshots.data!
                                                                          .docs[
                                                                      index]
                                                                  ['message'],
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          Text(
                                                            DateFormat.jm()
                                                                .format(
                                                                    datetime),
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Card(
                                                    elevation: 3,
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft:
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10))),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 3,
                                                            horizontal: 5),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 14.0,
                                                          horizontal: 8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            snapshots
                                                                .data!
                                                                .docs[index]
                                                                    ['sender']
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .amber),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            snapshots.data!
                                                                    .docs[index]
                                                                ['message'],
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Align(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              child: Text(
                                                                DateFormat.jm()
                                                                    .format(
                                                                        datetime),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .white),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        )
                                      : Container(
                                          child: Column(
                                            children: [
                                              Chip(
                                                label: Text(
                                                  DateFormat.yMMMd()
                                                      .format(datetime),
                                                  style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      fontSize: 13),
                                                ),
                                              ),
                                              Container(
                                                alignment:
                                                    snapshots.data!.docs[index]
                                                                ['sender'] ==
                                                            userModel.name
                                                        ? Alignment.centerRight
                                                        : Alignment.centerLeft,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      1.4,
                                                  child:
                                                      snapshots.data!.docs[
                                                                      index]
                                                                  ['sender'] ==
                                                              userModel.name
                                                          ? Card(
                                                              elevation: 5,
                                                              shape: const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              10),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10),
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              10))),
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          5),
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        16.0,
                                                                    horizontal:
                                                                        20.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        snapshots
                                                                            .data!
                                                                            .docs[index]['message'],
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      DateFormat
                                                                              .jm()
                                                                          .format(
                                                                              datetime),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : Card(
                                                              elevation: 3,
                                                              shape: const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              10),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              10))),
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          3,
                                                                      horizontal:
                                                                          5),
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        14.0,
                                                                    horizontal:
                                                                        8.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      snapshots
                                                                          .data!
                                                                          .docs[
                                                                              index]
                                                                              [
                                                                              'sender']
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.amber),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      snapshots
                                                                          .data!
                                                                          .docs[index]['message'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    Align(
                                                                        alignment:
                                                                            Alignment
                                                                                .bottomRight,
                                                                        child:
                                                                            Text(
                                                                          DateFormat.jm()
                                                                              .format(datetime),
                                                                          style: TextStyle(
                                                                              fontSize: 11,
                                                                              color: Colors.white),
                                                                        )),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                }),
                          ),
                          Container(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: TextFormField(
                                        controller: _messageController,
                                        decoration: InputDecoration(
                                          hintText: 'Send a message..',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(width: 100),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: FloatingActionButton(
                                      onPressed: () => createMessage(),
                                      elevation: 0,
                                      child: Icon(Icons.send),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height / 1.22,
                          child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Visibility(
                                visible: true,
                                child: IconButton(
                                    onPressed: () {
                                      _controller.jumpTo(_controller.position.maxScrollExtent);
                                    }, icon: Icon(Icons.arrow_drop_down_circle),color: Colors.grey,iconSize: 30,
                                    ),
                              )))
                    ],
                  ),
                );
        },
      ),
    );
  }

  Future createMessage() async {
    if (_messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": _messageController.text,
        "sender": userModel.name,
        "time": DateTime.now().millisecondsSinceEpoch
      };

      var docref = FirebaseFirestore.instance
          .collection('Classes')
          .doc(classModel['id'])
          .collection('Chats');

      await docref.add(chatMessageMap);
      _controller.animateTo(_controller.position.maxScrollExtent,
          curve: Curves.easeInOut, duration: Duration(milliseconds: 400));
      _messageController.clear();
    }
  }
}
