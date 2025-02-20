import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jogging_app/features/screans/home_screen.dart';
import 'package:jogging_app/shared/Navigation/app_route.dart';
import 'package:jogging_app/shared/Navigation/app_route_strings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your applicatio

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
       designSize: Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child){
          return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRoute.onGenerateRoute,
      navigatorKey: AppRoute.navkey,
      initialRoute: AppRouteStrings.navScreen,
    );
        }
    );
  }
}

