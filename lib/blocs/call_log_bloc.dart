import 'package:bloc/bloc.dart';
import 'package:call_logs/model/call_logs_model.dart';
import 'package:call_logs/repositories/call_log_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'call_log_event.dart';
part 'call_log_state.dart';

class CallLogBloc extends Bloc<CallLogEvent, CallLogState> {
  final CallLogRepository repository;
  final int _pageSize = 20;
  List<CallLogsModel> _allLogs = [];

  CallLogBloc({required this.repository}) : super(CallLogInitial()) {
    on<GetInitialCalllogs>((event, emit) async {
      emit(CallLogLoading());
      try {
        _allLogs = (await repository.getCallLogs()).toList();

        if (kDebugMode) {
          print("Fetched logs: ${_allLogs.length}");
        }

        final initialPage = _allLogs.take(_pageSize).toList();
        emit(
          CallLogLoaded(
            displayItems: initialPage,
            hasReachedMax: initialPage.length > _pageSize,
          ),
        );
      } catch (e) {
        emit(CallLogFailure(error: e.toString()));
      }
    });

    on<GetMoreCallLogs>((event, emit) async {
      if (kDebugMode) {
        print('GetMoreCallLogs event triggered');
      }
      final currentState = state;

      if (currentState is CallLogLoaded) {
        // Safety check - don't proceed if already at max
        if (currentState.hasReachedMax) return;

        try {
          final currentLength = currentState.displayItems.length;
          final nextItems =
              _allLogs.skip(currentLength).take(_pageSize).toList();

          if (nextItems.isEmpty) {
            emit(
              CallLogLoaded(
                hasReachedMax: true,
                displayItems: currentState.displayItems,
              ),
            );
            return;
          }

          final updatedList = List<CallLogsModel>.from(
            currentState.displayItems,
          )..addAll(nextItems);

          final hasReachedMax = updatedList.length >= _allLogs.length;

          if (kDebugMode) {
            print(
              'Updated length: ${updatedList.length}, All logs: ${_allLogs.length}',
            );
            print('Has reached max: $hasReachedMax');
          }

          emit(
            CallLogLoaded(
              hasReachedMax: hasReachedMax,
              displayItems: updatedList,
            ),
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error loading more logs: $e');
          }
        }
      }
    });
  }
}
