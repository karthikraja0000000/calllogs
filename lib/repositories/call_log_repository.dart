import 'package:call_logs/model/call_logs_model.dart';
import 'package:call_logs/services/api_service.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/foundation.dart';

class CallLogRepository {
  final ApiService apiService = ApiService();

  Future<Iterable<CallLogsModel>> getCallLogs() async {
    try {
      Iterable<CallLogEntry> entries = await CallLog.get();

      return entries.map((entry) {
        String callType;
        switch (entry.callType) {
          case CallType.rejected:
            callType = 'rejected';
            break;
          case CallType.incoming:
            callType = 'incoming';
            break;
          case CallType.outgoing:
            callType = 'outgoing';
            break;
          case CallType.missed:
            callType = 'missed';
            break;
          default:
            callType = 'unknown';
        }
        return CallLogsModel(
          phoneNumber: entry.number as String,
          dateTime: DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0),
          callType: callType,
          duration: (entry.duration ?? 0).toString(),
          name: entry.name ?? "Unknown",
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting call logs: $e');
      }
      return [];
    }
  }

  Future<bool> sendCallLogsToApi(CallLogsModel callLogs) async {
    try {
      return await apiService.createLeadFromCall(callLogs);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending call log to API: $e');
      }
      if (kDebugMode) {
        print('Exception in send call logs to api: $e');
      }
      throw Exception('Exception in send call logs to api: $e');
    }
  }
}
