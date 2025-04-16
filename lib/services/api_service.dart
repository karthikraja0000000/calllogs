import 'dart:convert';
import 'package:call_logs/model/call_logs_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String url ="";
      // "https://leads.akhomes.co.in/api/method/erpnext.api.lead_generate.create_lead_from_call";


  String formatPhoneNumber(String phoneNumber) {
    // Check if phone number already starts with '+'
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+$phoneNumber';
    }
    return phoneNumber;
  }

  Future<bool> createLeadFromCall(CallLogsModel callLogs) async {
    try {

      String formattedPhoneNumber = formatPhoneNumber(callLogs.phoneNumber);
      if (kDebugMode) {
        print("Phone Number: ${callLogs.phoneNumber}");
      }

      if (callLogs.phoneNumber.isEmpty) {
        throw Exception("Phone number is required.");
      }


      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'token 2134c2a23a530a5:04f77995138db16',
          'Content-Type': 'application/json',
        },

        body: jsonEncode({
          'first_name': callLogs.name.isNotEmpty ? callLogs.name : 'unknown',
          'phone_number': formattedPhoneNumber,
          'date_time': callLogs.dateTime.toIso8601String(),
          'call_type': callLogs.callType,
          'call_duration': int.tryParse(callLogs.duration) ?? 0,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await jsonDecode(response.body);
        if (kDebugMode) {
          print("Response :$responseData");
        }
        return true;
      } else {
        throw Exception('Failed to create lead: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating lead: $e');
      }
      throw Exception(e);
    }
  }
}
