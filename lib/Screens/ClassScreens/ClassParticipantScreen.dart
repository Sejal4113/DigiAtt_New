import 'package:flutter/material.dart';

import '../../methods/CLassModel.dart';

class ClassParticipantsScreen extends StatefulWidget {
  ClassModel classModel;

  ClassParticipantsScreen({Key? key, required this.classModel})
      : super(key: key);

  @override
  State<ClassParticipantsScreen> createState() =>
      _ClassParticipantsScreenState(classModel);
}

class _ClassParticipantsScreenState extends State<ClassParticipantsScreen> {
  var classModel;

  _ClassParticipantsScreenState(this.classModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Participants'),
    );
  }
}
