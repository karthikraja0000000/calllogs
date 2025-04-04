import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> callLogs = [
    {
      "name": "karthick",
      "number": "1231234567",
      "time": "12:13pm",
      "Call type": "Received",
      "Duration": "01:00 min",
    },
    {
      "name": "unknown",
      "number": "1231234567",
      "time": "11:13pm",
      "Call type": "Missed Call",
      "Duration": "00:00 min",
    },
    {
      "name": "karthick2",
      "number": "1231234567",
      "time": "11:03pm",
      "Call type": "Outgoing Call",
      "Duration": "01:06 min",
    },
    {
      "name": "leo",
      "number": "1231234567",
      "time": "10:43pm",
      "Call type": "Received",
      "Duration": "00:30 min",
    },
    {
      "name": "das",
      "number": "1231234567",
      "time": "09:53pm",
      "Call type": "Rejected",
      "Duration": "00:00 min",
    },
    {
      "name": "spam",
      "number": "1231234567",
      "time": "06:14pm",
      "Call type": "Missed Call",
      "Duration": "00:00 min",
    },
    {
      "name": "karthick3",
      "number": "1231234567",
      "time": "12:13Am",
      "Call type": "Received",
      "Duration": "05:30 min",
    },
    {
      "name": "karthick4",
      "number": "1231234567",
      "time": "12:00Am",
      "Call type": "Received",
      "Duration": "01:55 min",
    },
    {
      "name": "karthick4",
      "number": "1231234567",
      "time": "12:00Am",
      "Call type": "Received",
      "Duration": "01:55 min",
    },
    {
      "name": "karthick",
      "number": "1231234567",
      "time": "12:13pm",
      "Call type": "Received",
      "Duration": "01:00 min",
    },
    {
      "name": "unknown",
      "number": "1231234567",
      "time": "11:13pm",
      "Call type": "Missed Call",
      "Duration": "00:00 min",
    },
    {
      "name": "karthick2",
      "number": "1231234567",
      "time": "11:03pm",
      "Call type": "Outgoing Call",
      "Duration": "01:06 min",
    },
    {
      "name": "leo",
      "number": "1231234567",
      "time": "10:43pm",
      "Call type": "Received",
      "Duration": "00:30 min",
    },
    {
      "name": "das",
      "number": "1231234567",
      "time": "09:53pm",
      "Call type": "Rejected",
      "Duration": "00:00 min",
    },
    {
      "name": "spam",
      "number": "1231234567",
      "time": "06:14pm",
      "Call type": "Missed Call",
      "Duration": "00:00 min",
    },
    {
      "name": "karthick3",
      "number": "1231234567",
      "time": "12:13Am",
      "Call type": "Received",
      "Duration": "05:30 min",
    },
    {
      "name": "karthick4",
      "number": "1231234567",
      "time": "12:00Am",
      "Call type": "Received",
      "Duration": "01:55 min",
    },
    {
      "name": "karthick4",
      "number": "1231234567",
      "time": "12:00Am",
      "Call type": "Received",
      "Duration": "01:55 min",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              "assets/images/Back.svg",
              height: 25.h,
              width: 24.w,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.darken),
              // color: Colors.white,
            ),
          ),
          title: Text(
            'Calls',
            style: TextStyle(
              color: Colors.black,
              fontFamily: "source-sans-pro",
              fontSize: 16.r,
            ),
          ),
        ),

        body: ListView.builder(
          itemCount: callLogs.length,
          itemBuilder: (context, index) {
            final log = callLogs[index];
            return Card(
              color: Colors.white,
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 15.r,

                  child: Icon(_getCallIcon(log["Call type"]!),
                    color: _getCallColor(log["Call type"]!),),
                ),
                title: Text(
                  log["name"]!,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "source-sans-pro",
                    fontSize: 13.r,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      log["time"]!,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "source-sans-pro",
                        fontSize: 11.r,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      log["Call type"]!,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "source-sans-pro",
                        fontSize: 11.r,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  _showCalls(context, log);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

void _showCalls(BuildContext context, Map<String, String> log) {
  showModalBottomSheet(
    context: context,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SizedBox(
        height: 245.h,
        width: 360.w,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Padding(
              //   padding: EdgeInsets.only(left: 289.w),
              //   child: OutlinedButton(onPressed: (){Navigator.pop(context);}, child: Icon(Icons.clear)),
              // ),
              SizedBox(height: 10.h),
              Text(
                "Name: ${log['name']}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "source-sans-pro",
                  fontSize: 14.r,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Number: ${log['number']}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "source-sans-pro",
                  fontSize: 14.r,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Call Type: ${log['Call type']}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "source-sans-pro",
                  fontSize: 14.r,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Time: ${log['time']}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "source-sans-pro",
                  fontSize: 14.r,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Duration: ${log['Duration']}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "source-sans-pro",
                  fontSize: 14.r,
                ),
              ),
              SizedBox(height: 10.h),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              //   child: Container(
              //     height: 40.h,
              //     width: 324.w,
              //     decoration: BoxDecoration(color: Colors.grey),
              //     child: Center(
              //       child: Text(
              //         "close",
              //         style: TextStyle(
              //           color: Colors.black,
              //           fontFamily: "source-sans-pro",
              //           fontSize: 16.r,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      );
    },
  );
}


IconData _getCallIcon(String? callType) {
  switch (callType) {
    case "Missed Call":
      return Icons.call_missed;
    case "Received":
      return Icons.call_received;
    case "Outgoing Call":
      return Icons.call_made;
    case "Rejected":
      return Icons.call_end;
    default:
      return Icons.phone;
  }
}

Color _getCallColor(String? callType) {
  switch (callType) {
    case "Missed Call":
      return Colors.red;
    case "Received":
      return Colors.green;
    case "Outgoing Call":
      return Colors.blue;
    case "Rejected":
      return Colors.orange;
    default:
      return Colors.black54;
  }
}