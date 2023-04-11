import 'package:digiatt_new/Screens/ClassScreens/NewAssignment.dart';
import 'package:flutter/material.dart';

import '../../methods/CLassModel.dart';

class ClassAssignmentScreen extends StatefulWidget {
  ClassModel classModel;
  var userModel;

  ClassAssignmentScreen({Key? key, required this.classModel, required this.userModel}) : super(key: key);

  @override
  State<ClassAssignmentScreen> createState() =>
      _ClassAssignmentScreenState(classModel, userModel);
}

class _ClassAssignmentScreenState extends State<ClassAssignmentScreen> {
  var classModel,userModel;

  _ClassAssignmentScreenState(this.classModel, this.userModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(builder: (context, snapshots) {
        return Container();
      }),
      floatingActionButton: userModel.role == 'teacher' ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewAssignment(userModel: userModel, classModel: classModel,)));
        },
        child: Icon(Icons.add),
      ) : null,
    );
  }
}
