part of 'call_log_bloc.dart';

sealed class CallLogState extends Equatable {
  const CallLogState();
  @override
  List<Object> get props => [];
}

class CallLogInitial extends CallLogState {}

class CallLogLoading extends CallLogState{}

class CallLogLoaded extends CallLogState{
  final List<CallLogsModel> callLogsModel;

  const CallLogLoaded ({required this.callLogsModel});

}

class CallLogFailure extends CallLogState{
  final String error;

  const CallLogFailure({required this.error});
}

