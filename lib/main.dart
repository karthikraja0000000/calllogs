import 'package:call_logs/backgroundtask.dart';
import 'package:call_logs/blocs/call_log_bloc.dart';
import 'package:call_logs/home_page.dart';
import 'package:call_logs/repositories/call_log_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> requestPermission() async{
  await Permission.phone.request();
  if(await Permission.ignoreBatteryOptimizations.isDenied){
    await Permission.ignoreBatteryOptimizations.request();
  }
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermission();
  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CallLogBloc(repository: CallLogRepository()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: HomePage(),
          );
        },
      ),
    );
  }
}
