import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:open_file/open_file.dart';

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
  var isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('assignment'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Classes')
            .doc(classModel.id)
            .collection("Assignments")
            .doc(assign_data['id'].toString())
            .collection('Submission')
            .snapshots(),
        builder: (context, snapshots) {
          return snapshots.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.separated(
                  itemBuilder: (context, index) {
                    var data =
                        snapshots.data!.docs[0].data() as Map<String, dynamic>;
                    return ListTile(
                      // leading: Text((index + 1).toString()),
                      title: Text(data['name']),
                      subtitle: Text(data['email']),
                      trailing: InkWell(
                          onTap: () {
                            FileDownloader.downloadFile(
                              url: data['url'],
                              name: data['file_name'],
                              onProgress: (String? filename, double? progress) {
                                setState(() {
                                  isDownloading = true;
                                  downloadprog = progress!;
                                });
                              },
                              onDownloadCompleted: (String? path) {
                                try {
                                  OpenFile.open(path);
                                } on Exception catch (e) {
                                 snackbarKey.currentState!.showSnackBar(SnackBar(content: Text(e.toString())));
                                }

                                setState(() {
                                  isDownloading = false;
                                });
                              },
                              onDownloadError: (String error) {
                                snackbarKey.currentState!.showSnackBar(SnackBar(content: Text(error.toString())));
                            }
                            );
                          },
                          child: !isDownloading ? Icon(
                            Icons.download_for_offline,
                            size: 30,
                          ): CircularProgressIndicator(value: downloadprog,),),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: snapshots.data!.docs.length);
        },
      ),
    );
  }
}
