import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jogging_app/features/utils/location.dart';
import 'package:jogging_app/shared/app_colors.dart';
import 'package:jogging_app/shared/constants.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final UserLocation _userLocation = UserLocation();

  // State variables
  Duration _joggingDuration = Duration.zero;
  bool _isJogging = false;
  List<LatLng> _routes = [];
  Timer? _timer;
  LatLng _currentLocation = const LatLng(5.0377, 7.9128); // Default location
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _userLocation.getLocation();
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _markers = {
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: _currentLocation,
            ),
          };
        });
        await _goToLocation(_currentLocation);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _startLocationTracking() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Reduced from 100 for more accurate tracking
      ),
    ).listen((Position position) async {
      final newLocation = LatLng(position.latitude, position.longitude);
      await _goToLocation(newLocation);

      if (_isJogging) {
        setState(() {
          _routes.add(newLocation);
          _currentLocation = newLocation;
          _markers = {
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: newLocation,
            ),
          };
        });
      }
    });
  }

  void _startJogging() {
    setState(() {
      _isJogging = true;
      _joggingDuration = Duration.zero;
    });

    _startLocationTracking();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _joggingDuration = Duration(seconds: _joggingDuration.inSeconds + 1);
      });
    });
  }

  void _stopJogging() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    setState(() {
      _isJogging = false;
    });
  }

  Future<void> _goToLocation(LatLng location) async {
    final GoogleMapController controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 16,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            onMapCreated: _mapController.complete,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            polylines: {
              Polyline(
                polylineId: const PolylineId('Routes'),
                color: AppColors.appColor,
                width: 5,
                points: _routes,
              ),
            },
            markers: _markers,
          ),
          _buildTopBar(),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircularIconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icons.arrow_back_ios,
            ),
            const Text('Current Jogging'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('GPS'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Running Time',
                style: interStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.appBlack,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_joggingDuration),
                    style: interStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.appBlack,
                    ),
                  ),
                  JoggingButton(
                    isJogging: _isJogging,
                    onPressed: _isJogging ? _stopJogging : _startJogging,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const CircularIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      width: 32.w,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class JoggingButton extends StatelessWidget {
  final bool isJogging;
  final VoidCallback onPressed;

  const JoggingButton({
    super.key,
    required this.isJogging,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.appColor,
        ),
        child: Icon(
          isJogging ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }
}
