import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
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
            .doc(classModel['id'])
            .collection("Assignments")
            .doc(assign_data['id'].toString())
            .collection('Submission')
            .snapshots(),
        builder: (context, snapshots) {
          return snapshots.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : (snapshots.data?.docs.length == 0) ? Container(
            width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(width: 300,height:300,child: Image.asset('lib/assets/images/3973481.png')),
                          Text('No Submissions Yet',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(child: ElevatedButton(onPressed: showAlertDialog, child: Text('Delete Assignment'))),
                        ],
                      ),
                    )
                  ],
                ),
              ):Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListView.separated(shrinkWrap: true,
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
                                      OpenAppFile.open(path!);
                                    } on Exception catch (e) {
                                     snackbarKey.currentState!.showSnackBar(SnackBar(content: Text(e.toString())));
                                    }

                                        setState(() {
                                          isDownloading = false;
                                        });
                                      },
                                      onDownloadError: (String error) {
                                        snackbarKey.currentState!.showSnackBar(
                                            SnackBar(
                                                content: Text(error.toString())));
                                      });
                                },
                                child: !isDownloading
                                    ? Icon(
                                        Icons.download_for_offline,
                                        size: 30,
                                      )
                                    : CircularProgressIndicator(
                                        value: downloadprog,
                                      ),
                              ),
                            );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: snapshots.data!.docs.length),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(child: ElevatedButton(onPressed: () {
                          showAlertDialog();
                        }, child: Text('Delete Assignment'))),
                      ],
                    ),
                  )
                ],
              );

    },
      ),
    );
  }

  void showAlertDialog() {
    showDialog(barrierDismissible: false,context: context, builder: (context) {
      return AlertDialog(
        title: Text('Delete Assignment?'),
        content: Text('All the Assignment data will be lost'),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
          }, child: Text('Cancel')),
          TextButton(onPressed: () async {
            final instance = FirebaseFirestore.instance;
            final batch = instance.batch();
            var collection = instance.collection('Classes').doc(classModel['id']).collection('Assignments').doc(assign_data['id']).collection('Submissions');
            var snapshots = await collection.get();
            for (var doc in snapshots.docs) {
              batch.delete(doc.reference);
            }
            await batch.commit();
            FirebaseFirestore.instance.collection('Classes').doc(classModel['id']).collection('Assignments').doc(assign_data['id']).delete().then((value) {
              deleteFolder('files/assignments/${assign_data['id']}/');
              Navigator.pop(context);
              Navigator.pop(context);

            });
          }, child: Text('Yes'))
        ],
      );
    });
  }

  deleteFolder(path) async {
    var ref = await FirebaseStorage.instance.ref(path);
    ref.listAll()
        .then((dir) => {
    dir.items.forEach((fileRef) => this.deleteFile(ref.fullPath, fileRef.name)),
    dir.prefixes.forEach((folderRef) => this.deleteFolder(folderRef.fullPath))
    }).catchError((error) => print(error));


  }

  deleteFile(pathToFile, fileName) async {
    var ref = await FirebaseStorage.instance.ref(pathToFile);
    var childRef = ref.child(fileName);
    childRef.delete();
  }
}
