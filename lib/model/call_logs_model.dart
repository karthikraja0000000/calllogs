class CallLogsModel {
  final String name;
  final String phoneNumber;
  final DateTime dateTime;
  final String callType;
  final String duration;

  CallLogsModel({
    required this.phoneNumber,
    required this.dateTime,
    required this.callType,
    required this.duration,
    required this.name,
  });
}
//
//   Map<String,dynamic> toJson(){
//    return{
//      'Name' : name,
//      'Phone number' : phoneNumber,
//      'Date time':dateTime.toIso8601String(),
//      'Call type' : callType,
//      'Duration' : duration
//    };
//   }
//
//   factory CallLogsModel.fromJson(Map<String,dynamic> json){
//     return CallLogsModel(
//       name: json["Name"],
//       phoneNumber: json["Phone number"],
//       dateTime: DateTime.parse(json["Date time"]),
//       callType: json["Call type"],
//       duration: json["Duration"]
//     );
//   }
// }
