import 'dart:async';
import 'package:call_logs/blocs/call_log_bloc.dart';
import 'package:call_logs/model/call_logs_model.dart';
import 'package:call_logs/repositories/call_log_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<PhoneState>? _callStateSubscription;
  // bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    context.read<CallLogBloc>().add(GetInitialCallLogs());
    // _scrollController.addListener(_onScroll);

    // CallLogRepository()
    //     .getCallLogs()
    //     .then((logs) {
    //       if (kDebugMode) {
    //         print("Repo test - Logs: ${logs.length}");
    //       }
    //     })
    //     .catchError((e) {
    //       if (kDebugMode) {
    //         print("Repo test - Error: $e");
    //       }
    //     });

    _syncCallLogs();

    _listenToCallState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withAlpha(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  offset: Offset(0, 7),
                  blurRadius: 7,
                ),
              ],
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.blueGrey,
            ),
            child: Center(
              child: Text(
                "Your call logs are syncing",
                style: TextStyle(
                  fontFamily: "source-sans-pro",
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _listenToCallState() {
    _callStateSubscription = PhoneState.stream.listen((state) async {
      if (kDebugMode) {
        print("Call state: ${state.status}");
      }

      if (state.status == PhoneStateStatus.CALL_ENDED) {
        context.read<CallLogBloc>().add(AddMoreCallLogs());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _callStateSubscription?.cancel();
    super.dispose();
  }



  // void _onScroll() {
  //   if (_scrollController.position.extentAfter < 100 &&
  //       !_isLoadingMore) {  // Add a flag to prevent multiple triggers
  //
  //     _isLoadingMore = true;  // Set flag to prevent multiple triggers
  //
  //     final state = context.read<CallLogBloc>().state;
  //     if (state is CallLogLoaded && !state.hasReachedMax) {
  //       if (kDebugMode) {
  //         print("Fetching more call logs...");
  //       }
  //       context.read<CallLogBloc>().add(GetMoreCallLogs());
  //
  //       // Reset the flag after a small delay
  //       Future.delayed(Duration(milliseconds: 300), () {
  //         _isLoadingMore = false;
  //       });
  //     } else {
  //       _isLoadingMore = false;  // Reset flag if not loading
  //     }
  //   }
  // }

  Future<void> _syncCallLogs() async {
    try {
      final repo = CallLogRepository();
      final logs = await repo.getCallLogs();
      final prefs = await SharedPreferences.getInstance();
      final lastSentMills = prefs.getInt('last_sent_timestamp');
      final lastSent =
          lastSentMills != null
              ? DateTime.fromMillisecondsSinceEpoch(lastSentMills)
              : null;

      for (var log in logs) {
        if (lastSent == null || log.dateTime.isAfter(lastSent)) {
          final success = await repo.sendCallLogsToApi(log);
          if (success) {
            await prefs.setInt(
              'last_sent_timestamp',
              log.dateTime.millisecondsSinceEpoch,
            );
            if (kDebugMode) {
              print("BackgroundFetch: Sent log at ${log.dateTime}");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Sync error: $e");
      }
    }
  }

  Future<void> _manualSync() async {
    context.read<CallLogBloc>().add(AddMoreCallLogs());
  }

  String formatedDate(String dateTime) {
    final DateTime parsedDate = DateTime.parse(dateTime);
    final DateFormat formatter = DateFormat('HH:mm:ss');
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Calls',
            style: TextStyle(
              color: Colors.black,
              fontFamily: "source-sans-pro",
              fontSize: 16.r,
            ),
          ),
          actions: [
            Text(
              'StopSync',
              style: TextStyle(
                fontFamily: "source-sans-pro",
                color: Colors.black,
                fontSize: 12.r,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              onPressed: () {
                FlutterBackgroundService().invoke("stopServices");
              },
              icon: Icon(Icons.sync_disabled),
            ),
          ],
        ),

        body: RefreshIndicator(
          onRefresh: _manualSync,
          child: BlocConsumer<CallLogBloc, CallLogState>(
            listener: (context, state) {
              if (state is CallLogFailure) {
                if (kDebugMode) {
                  print(state.error);
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("something went wrong")));
              }
            },
            builder: (context, state) {
              if (kDebugMode) {
                print("HomePage rebuilt with state: $state");
              }
              if (state is CallLogLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CallLogLoaded) {
                if (kDebugMode) {
                  print("Loaded call logs: ${state.displayItems.length}");
                }

                final callLogs = state.displayItems;
                final hasReachedMax = state.hasReachedMax;

                if (kDebugMode) {
                  print(
                    "ListView builder: Loaded ${callLogs.length} logs, hasReachedMax: $hasReachedMax",
                  );
                }

                if (callLogs.isEmpty) {
                  return Center(child: Text("No call logs found"));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: callLogs.length + (hasReachedMax ? 0 : 1),
                  // itemCount: callLogs.length,

                  itemBuilder: (context, index) {
                    // if (index >= callLogs.length) {
                    //   // This is the loading indicator at the bottom
                    //   return const Padding(
                    //     padding: EdgeInsets.all(16.0),
                    //     child: Center(child: CircularProgressIndicator()),
                    //   );
                    // }
                    if (index >= callLogs.length) {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              context.read<CallLogBloc>().add(
                                GetMoreCallLogs(),
                              );
                            },
                            child: Container(
                              width: 135.w,
                              height: 32.h,
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                              ),
                              child: Center(
                                child: Text(
                                  'Load More',
                                  style: TextStyle(
                                    fontFamily: "source-sans-pro",
                                    fontSize: 12.r,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final log = callLogs[index];
                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 18.r,

                          child: Icon(
                            _getCallIcon(log.callType),
                            color: _getCallColor(log.callType),
                          ),
                        ),
                        title: Text(
                          log.name.isNotEmpty ? log.name : "Unknown",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "source-sans-pro",
                            fontSize: 13.r,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              formatedDate(log.dateTime.toString()),
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "source-sans-pro",
                                fontSize: 11.r,
                              ),
                            ),
                            SizedBox(width: 7.w),
                            Text(
                              log.callType,
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
                );
              } else {
                return Center(
                  child: Column(
                    children: [
                      Text(
                        "No Available data",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "source-sans-pro",
                          fontSize: 13.r,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<CallLogBloc>().add(GetInitialCallLogs());
                        },
                        child: Container(
                          height: 40.h,
                          width: 324.w,
                          decoration: BoxDecoration(color: Colors.red),
                          child: Text(
                            'Reload',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "source-sans-pro",
                              fontSize: 13.r,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                // return Center(
                //   child: CircularProgressIndicator(color: Colors.white),
                // );
              }
            },
          ),
        ),
      ),
    );
  }
}

void _showCalls(BuildContext context, CallLogsModel log) {
  String formatedDate(String dateTime) {
    final DateTime parsedDate = DateTime.parse(dateTime);
    final DateFormat formatter = DateFormat('HH:mm:ss');
    return formatter.format(parsedDate);
  }

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
              SizedBox(height: 10.h),
              Text(
                "Name: ${log.name.isNotEmpty ? log.name : "Unknown"}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "source-sans-pro",
                  fontSize: 14.r,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Number: ${log.phoneNumber}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "source-sans-pro",
                  fontSize: 14.r,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Call Type: ${log.callType}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "source-sans-pro",
                  fontSize: 14.r,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Time: ${formatedDate(log.dateTime.toString())}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "source-sans-pro",
                  fontSize: 14.r,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Duration: ${log.duration}",
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

IconData _getCallIcon(String callType) {
  switch (callType) {
    case "missed":
      return Icons.call_missed;
    case "received":
      return Icons.call_received;
    case "outgoing":
      return Icons.call_made;
    case "rejected":
      return Icons.call_end;
    default:
      return Icons.phone;
  }
}

Color _getCallColor(String callType) {
  switch (callType) {
    case "missed":
      return Colors.red;
    case "received":
      return Colors.green;
    case "outgoing":
      return Colors.blue;
    case "rejected":
      return Colors.orange;
    default:
      return Colors.black54;
  }
}
