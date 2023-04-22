import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/ClassScreens/NewAssignment.dart';
import 'package:digiatt_new/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import '../../methods/CLassModel.dart';
import '../SubmitAssignment.dart';

class ClassAssignmentScreen extends StatefulWidget {
  ClassModel classModel;
  var userModel;

  ClassAssignmentScreen(
      {Key? key, required this.classModel, required this.userModel})
      : super(key: key);

  @override
  State<ClassAssignmentScreen> createState() =>
      _ClassAssignmentScreenState(classModel, userModel);
}

class _ClassAssignmentScreenState extends State<ClassAssignmentScreen> {
  var classModel, userModel;

  _ClassAssignmentScreenState(this.classModel, this.userModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(builder: (context, snapshots) {
        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Classes')
                .doc(classModel.id)
                .collection('Assignments')
                .snapshots(),
            builder: (context, snapshots) {
              return snapshots.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        var data = snapshots.data!.docs[index].data() as Map<String, dynamic>;
                        
                        return Card(
                          child: Container(
                            margin: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(data['title'] , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                    Text('End Date : ${data['end_date']}',style: TextStyle(fontSize: 12),)
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Divider(),
                                Text('Instructions',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: data['description'] == '' ?  Text('No instructions'):Text(data['description']),
                                ),
                                SizedBox(height: 5,),
                                (data['file_name'] == 'File not Selected') ? Container() :InkWell(
                                  onTap: () {
                                    //You can download a single file
                                    FileDownloader.downloadFile(
                                        url: data['file_path'],
                                        name: data['file_name'],
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
                                          child: Text(data['file_name']),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(),
                                Row(
                                  children: [
                                    Expanded(child: ElevatedButton(onPressed: () {
                                      if(userModel.role == 'student')  {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitAssignment(assign_data: data, userModel: userModel, ClassModel: classModel)));
                                      }else{

                                      }
                                    }, child: userModel.role == 'teacher' ? Text('View Assignment') : Text('Submit Assignment'))),
                                  ],
                                )
                              ],
                            ),
                          ),
                          
                        );
                      },
                      itemCount: snapshots.data!.docs.length);
            });
      }),
      floatingActionButton: userModel.role == 'teacher'
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewAssignment(
                              userModel: userModel,
                              classModel: classModel,
                            )));
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }


}
