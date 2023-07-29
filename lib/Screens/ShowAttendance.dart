import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

class ShowAttendance extends StatefulWidget {
  var attend_data;
  var classModel;
  ShowAttendance({Key? key, required this.attend_data, required this.classModel}) : super(key: key);

  @override
  State<ShowAttendance> createState() => _ShowAttendanceState(attend_data,classModel);
}

class _ShowAttendanceState extends State<ShowAttendance> {
  var attend_data;
  var classModel;
  _ShowAttendanceState(this.attend_data, this.classModel);

  late List<AttData> attendanceData;
  late TooltipBehavior _tooltipBehavior;

  bool isLoading = true;
  int totalCount = 0;
  int presentPercent = 0;
  int absentPercent = 0;

  @override
  void initState() {
    getData();
    _tooltipBehavior = TooltipBehavior(
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Text(
                data.Label,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          );
        });
    super.initState();
  }

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
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: Column(
                          children: [
                            SfCircularChart(
                              legend: Legend(isVisible: true),
                              title: ChartTitle(
                                  text: 'Subject : ${attend_data['subject']}\n ${DateFormat('d MMM yyyy, h.mm a').format(DateTime.fromMillisecondsSinceEpoch(attend_data['timestamp']))}',
                                  textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              tooltipBehavior: _tooltipBehavior,
                              palette: [Colors.green,Colors.red],
                              series: <CircularSeries>[
                                PieSeries<AttData, String>(
                                  dataSource: attendanceData,
                                  xValueMapper: (AttData data, _) => data.status,
                                  yValueMapper: (AttData data,_) => data.count,
                                  dataLabelMapper:
                                      (AttData data, _) =>
                                  '${data.count}%',
                                  dataLabelSettings:
                                  DataLabelSettings(
                                      isVisible: true,
                                      showZeroValue: false,
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16)),
                                  enableTooltip: true,
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Text('Total Students : ${totalCount}',style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),),
                            )

                          ],
                        ),
                      ),
                      Card(
                        child: Column(
              children: [

                        ListTile(title: Text('Name of Student'),trailing: Text('Present'),
                          titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 18),
                          leadingAndTrailingTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black),),
                        Divider(color: Colors.black.withOpacity(0.6),),
                        Container(
                          child: ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                              itemBuilder: (context, index) {
                                var data = snapshots.data!.docs[index].data()
                                as Map<String, dynamic>;



                                return ListTile(
                                  title: Text(
                                    data['name'],
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(data['email']),
                                  trailing: (data['Present']) ? Icon(Icons.check_circle_outline_outlined, color: Colors.green,): Icon(Icons.cancel_outlined, color: Colors.red,),
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
                                        onPressed: () async {
                                          var metadata = await FirebaseFirestore.instance.collection('Classes').doc(classModel['id']).collection('Attendance').doc(attend_data['id']).get();
                                          var datetime = DateTime.fromMillisecondsSinceEpoch(metadata['timestamp']);
                                          List<List<String>> res_data = [[],[
                                            'Subject', '${metadata['subject']}'
                                          ],[
                                            'Date' , '${DateFormat.yMd().format(datetime)}'
                                          ],['Time','${DateFormat.jm().format(datetime)}'],[],[],[
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
                                          String filename = 'Attendance_Data_${metadata['subject']}_${DateFormat.yMd().format(datetime)}_${DateFormat.jm().format(datetime)}';
                                          List<String> header = [
                                            'Sr. No.',
                                            'Name',
                                            'Email',
                                            'Attendance'
                                          ];
                                          exportCSV.myCSV(header, res_data);
                                          // exportCSV.myCSV(header, res_data,'Attendance_Data_${metadata['subject']}_${DateFormat.yMd().format(datetime)}_${DateFormat.jm().format(datetime)}');
                                        },
                                        child: Text('Download CSV')))),
                          ],
                        )
              ],
            ),
                      ),
                    ],
                  ),
                );
          }),
    );
  }
  Future<void> getData() async {
    int presentCount = 0;
    int absentCount = 0;
    await FirebaseFirestore.instance
        .collection('Classes')
        .doc(classModel['id'])
        .collection('Attendance').doc(attend_data['id']).collection('Lists')
        .snapshots()
        .forEach((element) async {
        for (int i = 0; i < element.size; i++) {
          print(element.docs[i]['Present']);
          if (element.docs[i]['Present']) {
            presentCount++;
            totalCount++;
          } else {
            absentCount++;
            totalCount++;
          }
        }
        presentPercent = ((presentCount / totalCount) * 100).truncate();
        absentPercent = ((absentCount / totalCount) * 100).truncate();
        attendanceData = getChartData(
          presentPercent, absentPercent, presentCount, absentCount);


      setState(() {
        isLoading = false;
      });
    });
  }
}






List<AttData> getChartData(final presentval,final absentval,int presentCount,int absentCount) {
  final List<AttData> chartData = [
    AttData('Present', presentval, 'Present Students : ${presentCount}'),
    AttData('Absent', absentval, 'Absent Lectures : ${absentCount}')
  ];
  return chartData;
}

class AttData {
  AttData(this.status, this.count, this.Label);
  final String status;
  final int count;
  final String Label;
}
