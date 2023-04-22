import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import '../main.dart';
import '../methods/firebase_api.dart';

class SubmitAssignment extends StatefulWidget {
  var assign_data;
  var userModel;
  var ClassModel;
  SubmitAssignment({Key? key,required this.assign_data,required this.userModel,required this.ClassModel}) : super(key: key);

  @override
  State<SubmitAssignment> createState() => _SubmitAssignmentState(assign_data,userModel,ClassModel);
}

class _SubmitAssignmentState extends State<SubmitAssignment> {
  var assign_data;
  var userModel;
  var ClassModel;
  var user = FirebaseAuth.instance.currentUser!.uid;

  _SubmitAssignmentState(this.assign_data,this.userModel,this.ClassModel);

  File? file;
  var urlDownload;
  UploadTask? task;
  String filename = 'File not Selected';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(assign_data['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Description',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                Text('End Date :  '+assign_data['end_date']),
              ],
            ),
            Divider(),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(top: 8.0,bottom: 8,left: 16,right: 16),
              child: Text(assign_data['description']),
            ),
            SizedBox(height: 20,),
            Divider(),
            Text('Attached Files:', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            assign_data['file_name'] == 'File Not Selected' ? Container() : InkWell(
              onTap: () {
                //You can download a single file
                FileDownloader.downloadFile(
                    url: assign_data['file_path'],
                    name: assign_data['file_name'],
                    onProgress: (String? Filename, double progress) {
                    },
                    onDownloadCompleted: (String path) {
                      snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Download Completed. check ${path}')));
                    },
                    onDownloadError: (String error) {
                      snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Error : ${error}')));
                    });
              },
              child: Card(
                child: Row(
                  children: [
                    Icon(Icons.file_copy_rounded),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(assign_data['file_name']),
                    )
                  ],
                ),
              ),
            ),

            SizedBox(height: 20,),
            file == null ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('No file Selected'),
            ) : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(filename),
            ),

            SizedBox(height: 20,),
            Row(
              children: [
                Expanded(child: Container(margin: EdgeInsets.all(20),child: ElevatedButton(onPressed: () {
                  selectFiles();
                }, child: Text('Attach Files')))),
              ],
            ),
            task != null ?  buildUploadStatus(task!) : Container(),

            Row(
              children: [
                Expanded(child: Container(child: ElevatedButton(onPressed: () {
                  uploadFile();

                  var map = {
                    'name' : userModel.name,
                    'email' : userModel.email,
                    'id' : user,
                    'url' : urlDownload,
                  };
                  var ref = FirebaseFirestore.instance.collection('Classes').doc(ClassModel.id).collection('Assignments').doc(assign_data['id'].toString()).collection('Submission').doc(user);

                  ref.set(map).then((value) {
                    snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Assignment submitted')));
                    Navigator.pop(context);});
                }, child: Text('Submit Assignment')))),
              ],
            ),

          ],
        ),
      ),
    );
  }
  Future selectFiles() async{
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if(result == null) return;
    final path = result.files.single.path!;
    setState(() {
      file = File(path);
      filename = result.files.single.name;
    });
  }

  Future uploadFile() async{
    if(file == null) return;

    final destination = 'files/${user}/${filename}';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {

    });

    if(task == null) return;

    final snapshot = await task!.whenComplete(() {});
    urlDownload = await snapshot.ref.getDownloadURL();


  }

  Widget buildUploadStatus(UploadTask uploadTask) => StreamBuilder<TaskSnapshot>(
    stream: task?.snapshotEvents,
    builder: (context,snapshot) {
      if(snapshot.hasData) {
        final snap = snapshot.data!;
        final progress =snap.bytesTransferred / snap.totalBytes;
        final percent = (progress * 100).toStringAsFixed(2);

        return Center(child: Text('${percent} %', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),));
      }else{
        return Container();
      }
    },
  );
}
