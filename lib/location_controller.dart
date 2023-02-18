import 'package:location/location.dart';

class LocationController {
  final location = Location();

  LocationController();

  Future<bool> checkIfPermissionGranted() async {
    final permission = await location.hasPermission();
    return permission == PermissionStatus.granted;
  }

  Future<bool> setupPermissionService() async {
    final permission = await location.requestPermission();
    return permission == PermissionStatus.granted;
  }

  Stream<LocationData> getLocationStream() {
    return location.onLocationChanged;
  }

  LocationData? currentLocation;
}
