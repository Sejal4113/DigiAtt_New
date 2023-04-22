
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../methods/firebase_api.dart';


class NewAssignment extends StatefulWidget {
  var classModel, userModel;
  NewAssignment({Key? key, required this.userModel, required this.classModel})
      : super(key: key);

  @override
  State<NewAssignment> createState() =>
      _NewAssignmentState(userModel, classModel);
}

class _NewAssignmentState extends State<NewAssignment> {
  var userModel, classModel;
  _NewAssignmentState(this.userModel, this.classModel);


  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();

  final Formkey = GlobalKey<FormState>();

  File? file;
  DateTime Date = DateTime.now();
  var urlDownload;
  UploadTask? task;
  var user = FirebaseAuth.instance.currentUser!.uid;
  String filename = 'File not Selected';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0,right: 8.0),
        child: SingleChildScrollView(
          child: Form(
              key: Formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30,),
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Enter Title'),
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty) {
                        return 'Enter Title';
                      }
                    },
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: _description,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                        label: Text('Enter Description'),
                    ),
                    minLines: 3,
                    maxLines: 3,
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Deadline Date : ${Date.day}/${Date.month}/${Date.year}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(),
                      IconButton(
                        onPressed: () async {
                          DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: Date,
                            firstDate: DateTime(1999),
                            lastDate: DateTime(2300),
                          );

                          if (newDate == null) return;

                          setState(() {
                            Date = newDate;
                          });
                        },
                        icon: Icon(Icons.date_range_rounded),
                      ),
                    ],
                  ),
                  new Divider(thickness: 2,),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('Upload Files',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  ),

                  file == null ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('No file Selected'),
                  ) : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(filename),
                  ),

                  Row(
                    children: [
                      Expanded(child: Container(margin: EdgeInsets.only(left: 10,right: 10),child: ElevatedButton(onPressed: () async {
                        selectFiles();
                      }, child: Text('Select Files')))),
                    ],
                  ),
                  SizedBox(height: 5,),
                  task != null ?  buildUploadStatus(task!) : Container(),
                  SizedBox(height: 5,),
                  Divider(thickness: 2,),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8,right: 8),
                          child: ElevatedButton(onPressed: () async {
                            if(Formkey.currentState!.validate()){
                              if(Date.isAfter(DateTime.now())) {
                                uploadFile();

                                String  date = Date.day.toString()+'/'+Date.month.toString()+'/'+Date.year.toString();
                                var id = DateTime.now().millisecondsSinceEpoch;

                                var map = {
                                  'title' : _title.text.toString(),
                                  'description' : _description.text.toString(),
                                  'end_date' : date,
                                  'file_link' : urlDownload,
                                  'file_name' : filename,
                                  'id' : id
                                };

                                var ref = FirebaseFirestore.instance.collection('Classes').doc(classModel.id).collection('Assignments').doc(id.toString());

                                await ref.set(map).then((value) {
                                  snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Assignment posted')));
                                  Navigator.pop(context);
                                });


                              }else{
                                snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Please select a valid Deadline')));
                              }


                            }

                          }, child: Text('Post Assigment')),
                        ),
                      ),
                    ],
                  )
                ],
              )),
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
