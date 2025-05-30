part of 'call_log_bloc.dart';

abstract class CallLogEvent extends Equatable {
  const CallLogEvent();

  @override
  List<Object> get props => [];
}

class GetInitialCallLogs extends CallLogEvent{}

class GetMoreCallLogs extends CallLogEvent{}

class AddMoreCallLogs extends CallLogEvent{}



// class SendCallLogs extends CallLogEvent{
// final CallLogsModel callLogsModel;
//
// const SendCallLogs({required this.callLogsModel});
//
// @override
// List<Object> get props => [callLogsModel];
// }
