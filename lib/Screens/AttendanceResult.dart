import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

class AttendanceResult extends StatefulWidget {
  var attend_data;
  var classModel;
  AttendanceResult({Key? key, required this.attend_data, this.classModel})
      : super(key: key);

  @override
  State<AttendanceResult> createState() =>
      _AttendanceResultState(attend_data, classModel);
}

class _AttendanceResultState extends State<AttendanceResult> {
  var attend_data, classModel;
  _AttendanceResultState(this.attend_data, this.classModel);

  List<List<String>> res_data = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Data'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Classes')
              .doc(classModel.id)
              .collection('Attendance')
              .doc(attend_data['id'])
              .collection('List').snapshots(),
          builder: (context, snapshots) {
            return snapshots.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                  children: [
                    Container(
                      height: size.height * 0.8,
                      child: ListView.separated(
                          itemBuilder: (context, index) {
                            var data = snapshots.data!.docs[index].data() as Map<String,dynamic>;

                            var count = 1;

                            List<String> list  = [  count.toString(), data['name'], data['email']];
                            res_data.add(list);
                            count++;

                            return ListTile(
                              title: Text(data['name'],style: TextStyle(fontWeight: FontWeight.bold),),
                              subtitle: Text(data['email']),
                            );

                          },
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: snapshots.data!.docs.length),
                    ),
                    Row(
                      children: [
                        Expanded(child: Container(margin: EdgeInsets.only(left: 20,right: 20),child: ElevatedButton(onPressed: () {
                          List<String> header= ['Sr. No.', 'Name', 'Email'];

                          exportCSV.myCSV(header, res_data);

                        }, child: Text('Download CSV')))),
                      ],
                    )
                  ],
                );
          }),
    );
  }
}
