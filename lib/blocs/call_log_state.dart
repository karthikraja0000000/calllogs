part of 'call_log_bloc.dart';

sealed class CallLogState extends Equatable {
  const CallLogState();
  @override
  List<Object> get props => [];
}

class CallLogInitial extends CallLogState {}

class CallLogLoading extends CallLogState {}

class CallLogLoaded extends CallLogState {
  final List<CallLogsModel> displayItems;
  final bool hasReachedMax;

  const CallLogLoaded({
    required this.hasReachedMax,
    required this.displayItems,
  });

  @override
  List<Object> get props => [displayItems, hasReachedMax];

  CallLogLoaded copyWith({
    List<CallLogsModel>? displayItems,
    bool? hasReachedMax,
  }) {
    return CallLogLoaded(
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      displayItems: displayItems ?? this.displayItems,
    );
  }
}

class CallLogFailure extends CallLogState {
  final String error;

  const CallLogFailure({required this.error});
}
