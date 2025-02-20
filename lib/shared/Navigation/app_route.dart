import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jogging_app/features/screans/activity_screen.dart';
import 'package:jogging_app/features/screans/home_screen.dart';
import 'package:jogging_app/features/screans/profle_screen.dart';
import 'package:jogging_app/features/utils/bottom_nav_screen.dart';
import 'package:jogging_app/shared/Navigation/app_route_strings.dart';

class AppRoute {
  
 static final navkey = GlobalKey<NavigatorState>();

static Route onGenerateRoute(RouteSettings settings){
  switch (settings.name) {
    case AppRouteStrings.homeScreen:
      return CupertinoPageRoute(builder: (_){
        return HomeScreen();
      });

      case AppRouteStrings.profileScreen:
      return CupertinoPageRoute(builder: (_){
        return ProfileScreen();
      });

       case AppRouteStrings.activityScreen:
      return CupertinoPageRoute(builder: (_){
        return ActivityScreen();
      });
    case AppRouteStrings.navScreen:
      return CupertinoPageRoute(builder: (_){
        return BottomNavScreen();
      });
    default:
    return CupertinoPageRoute(builder: (_){
        return HomeScreen();
      });
  }
}

  static void push(String name, {Object? arg}){
    navkey.currentState?.pushNamed(name, arguments: arg);
  }

  static void pushClear(String name, {Object? arg}){
    navkey.currentState?.pushReplacementNamed(name, arguments: arg);
  }

  static void pop ({Object? arg}){
    navkey.currentState?.pop(arg);
  }
}