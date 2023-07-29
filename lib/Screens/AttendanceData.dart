import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceData extends StatefulWidget {
  var classModel;
  AttendanceData({Key? key,required this.classModel}) : super(key: key);

  @override
  State<AttendanceData> createState() => _AttendanceDataState(classModel);
}

class _AttendanceDataState extends State<AttendanceData> {
  DateTimeRange SelectedDates = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  var classModel;
  var firstDate,lastDate;
  final subLists = [];
  final FormKey = GlobalKey<FormState>();
  var initialvalue;

  _AttendanceDataState(this.classModel);


  @override
  void initState() {
    getDates();
    for (int i = 0; i < classModel['subjects'].length; i++) {
      subLists.add(classModel['subjects'][i]);
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: FormKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32.0),
                        child: DropdownButtonFormField(
                          validator: (value) => (value == null)
                              ? 'Please Select Subject'
                              : null,
                          hint: Text('Select Subjects'),
                          isExpanded: true,
                          value: initialvalue,
                          items: subLists
                              .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              initialvalue = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symme(horizontal: 32.0,),
                      child: Text('Select Date Range',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                    ),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          final DateTimeRange? dateTimeRange = await showDateRangePicker(context: context, firstDate: firstDate, lastDate: lastDate);
                          if(dateTimeRange != null) {
                            setState(() {
                              SelectedDates = dateTimeRange;
                            });

                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: const Offset(
                                  0.0,
                                  2.0,
                                ),
                                blurRadius: 1.0,
                                spreadRadius: 1.0,
                              ), //BoxShadow
                              BoxShadow(
                                color: Colors.white,
                                offset: const Offset(0.0, 0.0),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                            ],
                            border: Border.all(width: 1,color: Colors.grey),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_month),
                                Text('    ${DateFormat('d / MMM / yyyy').format(SelectedDates.start)}   -   ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                Text('${DateFormat('d / MMM / yyyy').format(SelectedDates.end)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getDates() async {
    var stream = await FirebaseFirestore.instance.collection('Classes').doc(classModel['id']).collection('Attendance').orderBy('timestamp').snapshots().first;
    setState(() {
      firstDate = DateTime.fromMillisecondsSinceEpoch(stream.docs[0].data()['timestamp']);
      lastDate = DateTime.fromMillisecondsSinceEpoch(stream.docs[stream.docs.length -1].data()['timestamp']);
    });
  }
}
