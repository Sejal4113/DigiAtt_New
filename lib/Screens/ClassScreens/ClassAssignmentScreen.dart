import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/ClassScreens/NewAssignment.dart';
import 'package:digiatt_new/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import '../../methods/CLassModel.dart';
import '../CheckAssignment.dart';
import '../SubmitAssignment.dart';

class ClassAssignmentScreen extends StatefulWidget {
  var classModel;
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
                .doc(classModel['id'])
                .collection('Assignments')
                .snapshots(),
            builder: (context, snapshots) {
              if(snapshots.hasData) {
                return snapshots.connectionState == ConnectionState.waiting
                    ? Center(
                  child: CircularProgressIndicator(),
                ) : (snapshots.data!.docs.length == 0)
                    ? Center(child: Text('No Assignments Added'),)
                    : ListView.builder(
                    itemBuilder: (context, index) {
                      var data = snapshots.data!.docs[index].data() as Map<
                          String,
                          dynamic>;

                      return ListTile(
                        onTap: () => !
                        (userModel.role == 'teacher') ? Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) =>
                                SubmitAssignment(assign_data: data,
                                    userModel: userModel,
                                    ClassModel: classModel))) : Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) =>
                                CheckAssignment(assign_data: data,
                                    userModel: userModel,
                                   classModel: classModel,))),
                        leading: CircleAvatar(
                          child: Icon(Icons.book),
                        ),
                        title: Text(data['title']),
                        subtitle: Text("End Date : "+data['end_date']),
                      );
                    },
                    itemCount: snapshots.data!.docs.length) ;
              }else{
                return Center(child: Text('Error has occured'),);
              }
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
