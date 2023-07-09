import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/PDFViewer.dart';
import 'package:digiatt_new/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:intl/intl.dart';
import 'package:open_app_file/open_app_file.dart';

class CheckAssignment extends StatefulWidget {
  var assign_data;
  var classModel, userModel;
  CheckAssignment(
      {Key? key,
      required this.userModel,
      required this.classModel,
      required this.assign_data})
      : super(key: key);

  @override
  State<CheckAssignment> createState() =>
      _CheckAssignmentState(userModel, classModel, assign_data);
}

class _CheckAssignmentState extends State<CheckAssignment> {
  var userModel, classModel, assign_data;
  _CheckAssignmentState(this.userModel, this.classModel, this.assign_data);

  var downloadprog = 0.0;
  bool unchecked = false;
  final TextEditingController _controller = TextEditingController();
  final FormKey = GlobalKey<FormState>();
  bool late = false;
  var isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('assignment'),
      ),
      body: StreamBuilder(
        stream: GetStream(),
        builder: (context, snapshots) {
          return snapshots.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : (snapshots.data?.docs.length == 0)
                  ? Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    width: 300,
                                    height: 300,
                                    child: Image.asset(
                                        'lib/assets/images/3973481.png')),
                                Text(
                                  'No Submissions Yet',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: ElevatedButton(
                                        onPressed: showAlertDialog,
                                        child: Text('Delete Assignment'))),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 50,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  FilterChip(
                                    label: Text('Unchecked Submissions'),
                                    onSelected: (bool result) {
                                      unchecked = result;
                                      setState(() {});
                                    },
                                    selected: unchecked,
                                    showCheckmark: true,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  FilterChip(
                                      label: Text('Late Submissions'),
                                      selected: late,
                                      onSelected: (bool result) {
                                        setState(() {
                                          late = result;
                                        });
                                      })
                                ],
                              ),
                            ),
                            ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var data = snapshots.data!.docs[0].data()
                                      as Map<String, dynamic>;

                                  var submit_date =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          data['submit_date']);
                                  var end_date =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          assign_data['end_date']);
                                  return Dismissible(
                                    key: Key(data['name']),
                                    background: slideLeftBackground(),
                                    direction: DismissDirection.startToEnd,
                                    confirmDismiss: (direction) async {
                                      if (direction ==
                                          DismissDirection.startToEnd) {
                                        final bool res = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: Text(
                                                    "Do you want to revert the assignment for ${data['name']} ?"),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text(
                                                      "Cancel",
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    child: Text(
                                                      "Delete",
                                                    ),
                                                    onPressed: () async {
                                                      await FirebaseFirestore.instance.collection('Classes').doc(classModel['id']).collection('Assignments').doc(assign_data['id']).collection('Submission').doc(data['id']).delete();

                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.red),
                                                  ),
                                                ],
                                              );
                                            });
                                        return res;
                                      }
                                    },
                                    child: Card(
                                      child: ExpansionTile(
                                        title: Text(data['name']),
                                        subtitle: Text(data['email']),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                new Divider(
                                                  thickness: 2,
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Submit Date : ${DateFormat.yMd().format(submit_date)}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    (submit_date
                                                            .isAfter(end_date))
                                                        ? Text(
                                                            'late',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        : Text(
                                                            'On time',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Marks Assigned : ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    (data['marks'] == null)
                                                        ? Text(
                                                            'Not Assigned',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic),
                                                          )
                                                        : Text(
                                                            '${data['marks']} / 10',
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                InkWell(
                                                    onTap: () => Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                            builder: (context) => PDFViewer(
                                                                submission_data:
                                                                    data,
                                                                assign_id:
                                                                    assign_data[
                                                                        'id'],
                                                                class_id:
                                                                    classModel[
                                                                        'id']))),
                                                    child: ListTile(
                                                      leading: Icon(
                                                          Icons.picture_as_pdf),
                                                      title: Text(
                                                          data['file_name']),
                                                    )),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: TextButton(
                                                      onPressed: () async {
                                                        final bool res = await showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Do you want to revert the assignment for ${data['name']} ?"),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    child: Text(
                                                                      "Cancel",
                                                                    ),
                                                                    onPressed: () {
                                                                      Navigator.of(context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                  ElevatedButton(
                                                                    child: Text(
                                                                      "Delete",
                                                                    ),
                                                                    onPressed: () async {
                                                                      await FirebaseFirestore.instance.collection('Classes').doc(classModel['id']).collection('Assignments').doc(assign_data['id']).collection('Submission').doc(data['id']).delete();
                                                                      Navigator.of(context)
                                                                          .pop();
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                        backgroundColor:
                                                                        Colors.red),
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      },
                                                      child: Text(
                                                        'Revert',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    )),
                                                    Expanded(
                                                        child: ElevatedButton(
                                                      onPressed: () {
                                                        if (data['marks'] !=
                                                            null) {
                                                         snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Marks already assigned for ${data['name']}')));
                                                        } else {
                                                          DisplayBottomSheet(
                                                              data);
                                                        }
                                                      },
                                                      child:
                                                          Text('Assign Marks'),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors.green),
                                                    ))
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider();
                                },
                                itemCount: snapshots.data!.docs.length),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        showAlertDialog();
                                      },
                                      child: Text('Delete Assignment'))),
                            ],
                          ),
                        )
                      ],
                    );
        },
      ),
    );
  }

  Future DisplayBottomSheet(Map<String, dynamic> data) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        builder: (context) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: 250,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter marks for ${data['name']}',
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
                      Form(
                        key: FormKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.numberWithOptions(
                                decimal: false, signed: false),
                            maxLines: 1,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter marks';
                              } else if (int.parse(value) > 10) {
                                return 'Enter a value between 0 to 10';
                              } else {
                                return null;
                              }
                            },
                            controller: _controller,
                            decoration: InputDecoration(
                              label: Text('Enter Marks..'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  onPressed: () async {
                                    if (FormKey.currentState!.validate()) {
                                      await FirebaseFirestore.instance
                                          .collection('Classes')
                                          .doc(classModel['id'])
                                          .collection('Assignments')
                                          .doc(assign_data['id'])
                                          .collection('Submission')
                                          .doc(data['id'])
                                          .update({
                                        'marks':
                                            _controller.text.trim().toString()
                                      });
                                      _controller.clear();
                                      Navigator.pop(context);
                                      snackbarKey.currentState!.showSnackBar(
                                          SnackBar(
                                              content: Text('Marks assigned')));
                                    }
                                  },
                                  child: Text('confirm marks'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  Stream GetStream() {
    if (unchecked && late) {
      return FirebaseFirestore.instance
          .collection('Classes')
          .doc(classModel['id'])
          .collection("Assignments")
          .doc(assign_data['id'].toString())
          .collection('Submission')
          .where('submit_date', isGreaterThan: assign_data['end_date'])
          .orderBy('marks')
          .snapshots();
    } else if (unchecked && !late) {
      return FirebaseFirestore.instance
          .collection('Classes')
          .doc(classModel['id'])
          .collection("Assignments")
          .doc(assign_data['id'].toString())
          .collection('Submission')
          .where('submit_date', isGreaterThan: assign_data['end_date'])
          .snapshots();
    } else if (!unchecked && late) {
      return FirebaseFirestore.instance
          .collection('Classes')
          .doc(classModel['id'])
          .collection("Assignments")
          .doc(assign_data['id'].toString())
          .collection('Submission')
          .orderBy('marks')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('Classes')
          .doc(classModel['id'])
          .collection("Assignments")
          .doc(assign_data['id'].toString())
          .collection('Submission')
          .snapshots();
    }
  }

  void showAlertDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Assignment?'),
            content: Text('All the Assignment data will be lost'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    final instance = FirebaseFirestore.instance;
                    final batch = instance.batch();
                    var collection = instance
                        .collection('Classes')
                        .doc(classModel['id'])
                        .collection('Assignments')
                        .doc(assign_data['id'])
                        .collection('Submissions');
                    var snapshots = await collection.get();
                    for (var doc in snapshots.docs) {
                      batch.delete(doc.reference);
                    }
                    await batch.commit();
                    FirebaseFirestore.instance
                        .collection('Classes')
                        .doc(classModel['id'])
                        .collection('Assignments')
                        .doc(assign_data['id'])
                        .delete()
                        .then((value) {
                      deleteFolder('files/assignments/${assign_data['id']}/');
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Yes'))
            ],
          );
        });
  }

  deleteFolder(path) async {
    var ref = await FirebaseStorage.instance.ref(path);
    ref
        .listAll()
        .then((dir) => {
              dir.items.forEach(
                  (fileRef) => this.deleteFile(ref.fullPath, fileRef.name)),
              dir.prefixes
                  .forEach((folderRef) => this.deleteFolder(folderRef.fullPath))
            })
        .catchError((error) => print(error));
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  deleteFile(pathToFile, fileName) async {
    var ref = await FirebaseStorage.instance.ref(pathToFile);
    var childRef = ref.child(fileName);
    childRef.delete();
  }
}
