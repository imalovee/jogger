import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jogging_app/features/utils/location.dart';
import 'package:jogging_app/shared/app_colors.dart';
import 'package:jogging_app/shared/assets.dart';
import 'package:jogging_app/shared/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
   Completer<GoogleMapController> _mapController = Completer();
  UserLocation userLocation = UserLocation();
   Duration joggingDuration = Duration();
 bool isJogging = false;
 List<LatLng> routes = [];
 int seconds = 0;
 late Timer timer;
  double? lat;
  double? lon;

 void currentPosition(){
   Geolocator.getPositionStream(
     locationSettings: LocationSettings(
         accuracy: LocationAccuracy.high,
       distanceFilter: 100
     )
   ).listen((Position position){
     lat = position.latitude;
     lon = position.longitude;
      setState(() {
        if(isJogging){
          routes.add(LatLng(lat ?? 5.0377, lon ?? 7.9128));
        }
      });
    }
    );
  }

  void startJogging(){
    setState(() {
      isJogging = true;
      seconds = 0;
      //routes.clear();
    });

  timer = Timer.periodic(Duration(seconds: 1), (timer){
    setState(() {
      joggingDuration = Duration(seconds: joggingDuration.inSeconds + 1);

    });
  });
  }

  void stopJogging(){
    timer.cancel();
    setState(() {
      isJogging = false;
    });
  }

  @override
  void initState(){
    super.initState();
    userLocation.getLocation().then((value){
      lat = value.latitude;
      lon = value.longitude;
      print("User's Position: $lat, $lon");
    });
    currentPosition();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(lat ?? 5.0377, lon ?? 7.9128),
            zoom: 15
            ),
            onMapCreated: (mapController){
              _mapController.complete(mapController);
            },
            myLocationEnabled: true,
            polylines: {
              Polyline(
                polylineId: PolylineId('Routes'),
                color: AppColors.appColor,
                width: 10,
                visible: true,
                points: routes,
                )
            },
            markers: {
              Marker(
                markerId: MarkerId('currentLocation'),
                position: LatLng(lat ?? 5.0377, lon ?? 7.9128),
              ),
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle
                    ),
                    child: IconButton(onPressed: (){
                      Navigator.pop(context);
                    },
                        icon: Icon(Icons.arrow_back_ios)),
                  ),
                  Text('Current Jogging'),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle
                    ),
                    child: Text('GPS'),
                  ),
                ],
              ),),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              height: 176,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                // boxShadow: [
                //    BoxShadow(
                //     spreadRadius: 2,
                //       offset: Offset(0, 2),
                //       blurRadius: 10
                //    )

                // ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Running Time',
                  style: interStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.appBlack
                  ),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(formatDuration(joggingDuration),
                  style: interStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appBlack
                  ),),
                      GestureDetector(
                        onTap: isJogging? stopJogging : startJogging,
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.appColor,
                            shape: BoxShape.rectangle,

                          ),
                          child: Icon( isJogging?  Icons.pause : Icons.play_arrow,
                          color: Colors.white,),
                        ),
                      )
                    ],
                  )
                ],
              ),
                        ),
            ),
          )
          ],
      )
    );
  }
}





        