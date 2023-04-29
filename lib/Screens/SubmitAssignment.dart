import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:open_file/open_file.dart';

import '../main.dart';
import '../methods/firebase_api.dart';

class SubmitAssignment extends StatefulWidget {
  var assign_data;
  var userModel;
  var ClassModel;
  SubmitAssignment(
      {Key? key,
      required this.assign_data,
      required this.userModel,
      required this.ClassModel})
      : super(key: key);

  @override
  State<SubmitAssignment> createState() =>
      _SubmitAssignmentState(assign_data, userModel, ClassModel);
}

class _SubmitAssignmentState extends State<SubmitAssignment> {
  var assign_data;
  var userModel;
  var ClassModel;
  var user = FirebaseAuth.instance.currentUser!.uid;

  _SubmitAssignmentState(this.assign_data, this.userModel, this.ClassModel);

  File? file;
  UploadTask? task;
  String filename = 'File not Selected';
  double downloadprog = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(assign_data['title']),
        ),
        body: FutureBuilder(
            future: isDocumentExists(),
            builder: (context, snap) {
              if (snap.hasData) {
                var data = snap.data!.data();
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          (assign_data['description'] == '')
                              ? Container()
                              : Container(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Description',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0,
                                            bottom: 8,
                                            left: 16,
                                            right: 16),
                                        child: Text(assign_data['description']),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                ),
                          data['file_name'] == 'File not Selected'
                              ? Container()
                              : Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Text(
                                          'Attached Files:',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.black)),
                                        child: ListTile(
                                          onTap: () {
                                            FileDownloader.downloadFile(
                                                url: data['url'],
                                                name: data['file_name'],
                                              onDownloadCompleted: (String path) {
                                                print('FILE DOWNLOADED TO PATH: $path');
                                                // OpenFile.open(path); //TODO THIS STATEMENT NOT WORKING
                                              },
                                                onProgress: (String? filename,
                                                    double? progress) {
                                                  setState(() {
                                                    downloadprog = progress!;
                                                  });
                                                },);
                                          },
                                          leading: Icon(Icons.picture_as_pdf),
                                          title: Text(data['file_name']),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      child: ElevatedButton(
                                          onPressed: task != null
                                              ? null
                                              : () {
                                                  var ref = FirebaseFirestore
                                                      .instance
                                                      .collection('Classes')
                                                      .doc(ClassModel.id)
                                                      .collection('Assignments')
                                                      .doc(assign_data['id']
                                                          .toString())
                                                      .collection('Submission')
                                                      .doc(user);

                                                  ref.delete().then((value) {
                                                    snackbarKey.currentState!
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Assignment withdrawn')));
                                                    Navigator.pop(context);
                                                  });
                                                },
                                          child: Text('UnSubmit Assignment')))),
                            ],
                          ),
                          !(downloadprog == 0.0)
                              ? Container()
                              : Container(
                                  child: LinearProgressIndicator(
                                    value: downloadprog,
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                );
              }else{
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        (assign_data['description'] == '')
                            ? Container()
                            : Container(
                                child: Column(
                                  children: [
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8,
                                          left: 16,
                                          right: 16),
                                      child: Text(assign_data['description']),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                        assign_data['file_name'] == 'File not Selected'
                            ? Container()
                            : Container(
                                child: Column(
                                  children: [
                                    Divider(),
                                    Text(
                                      'Attached Files:',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.picture_as_pdf),
                                      title: Text(assign_data['file_name']),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Attachments',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      'End Date :  ' + assign_data['end_date']),
                                ],
                              ),
                              new Divider(),
                              SizedBox(
                                height: 10,
                              ),
                              file == null
                                  ? Container(
                                      child: Text('No Attached Files'),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(11),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          child: Icon(Icons.book_rounded),
                                        ),
                                        title: Text(filename),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                                    child: ElevatedButton(
                                        onPressed: file == null
                                            ? () {
                                                selectFiles();
                                              }
                                            : null,
                                        child: Text('Attach Files')))),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                                    child: ElevatedButton(
                                        onPressed: task != null
                                            ? null
                                            : () {
                                                uploadFile().then((value) {
                                                  var map = {
                                                    'name': userModel.name,
                                                    'email': userModel.email,
                                                    'id': user,
                                                    'url': value,
                                                    'file_name': filename
                                                  };
                                                  var ref = FirebaseFirestore
                                                      .instance
                                                      .collection('Classes')
                                                      .doc(ClassModel.id)
                                                      .collection('Assignments')
                                                      .doc(assign_data['id']
                                                          .toString())
                                                      .collection('Submission')
                                                      .doc(user);

                                                  ref.set(map).then((value) {
                                                    snackbarKey.currentState!
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Assignment submitted')));
                                                    Navigator.pop(context);
                                                  });
                                                });
                                              },
                                        child: Text('Submit Assignment')))),
                          ],
                        ),
                        task != null ? buildUploadStatus(task!) : Container(),
                      ],
                    ),
                  ],
                ),
              );
            }
            }));
  }

  Future selectFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;
    setState(() {
      file = File(path);
      filename = result.files.single.name;
    });
  }

  Future uploadFile() async {
    if (file == null) return;

    final destination = 'files/${user}/${filename}';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    String urlDownload = await snapshot.ref.getDownloadURL();
    return urlDownload;
  }

  Widget buildUploadStatus(UploadTask uploadTask) =>
      StreamBuilder<TaskSnapshot>(
        stream: task?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;

            return Center(
                child: LinearProgressIndicator(
              value: progress,
            ));
          } else {
            return Container();
          }
        },
      );

  Future isDocumentExists() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('Classes')
        .doc(ClassModel.id)
        .collection('Assignments')
        .doc(assign_data['id'].toString())
        .collection('Submission')
        .doc(user)
        .get();

    if (doc.exists) {
      return doc;
    } else {
      return null;
    }
  }
}
