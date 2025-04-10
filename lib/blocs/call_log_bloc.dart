import 'package:bloc/bloc.dart';
import 'package:call_logs/model/call_logs_model.dart';
import 'package:call_logs/repositories/call_log_repository.dart';
import 'package:equatable/equatable.dart';

part 'call_log_event.dart';
part 'call_log_state.dart';

class CallLogBloc extends Bloc<CallLogEvent, CallLogState> {
  final CallLogRepository repository;
  CallLogBloc({required this.repository}) : super(CallLogInitial()) {
    on<CallLogEvent>((event, emit) async {
      emit(CallLogLoading());
      try {
        final callLogs = await repository.getCallLogs();
        emit(CallLogLoaded(callLogsModel: callLogs.toList()));
      } catch (e) {
        emit(CallLogFailure(error: e as String));
      }
    });
  }
}
