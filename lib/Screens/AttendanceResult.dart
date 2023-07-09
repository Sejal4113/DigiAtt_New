import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/main.dart';
import 'package:flutter/material.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

class AttendanceResult extends StatefulWidget {
  var attend_data;
  var classModel;
  AttendanceResult(
      {Key? key, required this.attend_data, required this.classModel})
      : super(key: key);

  @override
  State<AttendanceResult> createState() =>
      _AttendanceResultState(attend_data, classModel);
}

class _AttendanceResultState extends State<AttendanceResult> {
  var attend_data, classModel;
  _AttendanceResultState(this.attend_data, this.classModel);



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
              .doc(classModel['id'])
              .collection('Attendance')
              .doc(attend_data['id'])
              .collection('Lists')
              .snapshots(),
          builder: (context, snapshots) {
            return snapshots.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      ListTile(title: Text('Name of Student'),trailing: Text('Present'),
                      titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 16),
                      leadingAndTrailingTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black),),
                      Divider(color: Colors.black.withOpacity(0.6),),
                      Container(
                        height: size.height * 0.75,
                        child: ListView.separated(
                            itemBuilder: (context, index) {
                              var data = snapshots.data!.docs[index].data()
                                  as Map<String, dynamic>;



                              return InkWell(
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection('Classes')
                                      .doc(classModel['id'])
                                      .collection('Attendance')
                                      .doc(attend_data['id'])
                                      .collection('Lists')
                                      .doc(data['id'])
                                      .update({
                                    'Present': !data['Present'],
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    data['name'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(data['email']),
                                  trailing: Checkbox(
                                    value: data['Present'],
                                    activeColor: Theme.of(context).colorScheme.primary,
                                    onChanged: (bool? value) async {
                                      await FirebaseFirestore.instance
                                          .collection('Classes')
                                          .doc(classModel['id'])
                                          .collection('Attendance')
                                          .doc(attend_data['id'])
                                          .collection('Lists')
                                          .doc(data['id'])
                                          .update({
                                        'Present': !data['Present'],
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => Divider(),
                            itemCount: snapshots.data!.docs.length),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        List<List<String>> res_data = [[
                                          'Sr. No.',
                                          'Name',
                                          'Email',
                                          'Attendance'
                                        ]];
                                        var count = 1;
                                        for(int i=0;i< snapshots.data!.docs.length ; i++) {
                                          var data = snapshots.data!.docs[i].data() as Map<String,dynamic>;


                                          if(data['Present']) {
                                            List<String> list = [
                                              count.toString(),
                                              data['name'],
                                              data['email'],
                                              'Present'
                                            ];
                                            res_data.add(list);
                                            count++;
                                          }else{
                                            List<String> list = [
                                              count.toString(),
                                              data['name'],
                                              data['email'],
                                              'Absent'
                                            ];
                                            res_data.add(list);
                                            count++;
                                          }


                                        }
                                        List<String> header = [
                                          'Sr. No.',
                                          'Name',
                                          'Email',
                                          'Attendance'
                                        ];

                                        exportCSV.myCSV(header, res_data);
                                      },
                                      child: Text('Download CSV')))),
                        ],
                      )
                    ],
                  );
          }),
    );
  }
}
