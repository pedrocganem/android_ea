// ignore_for_file: file_names

class GNSSLocation {
  String? receiverType;
  double? latitude;
  double? longitude;
  String? latitudeDirection;
  String? longitudeDirection;
  double? altitude;
  String? utcOfPositionFix;
  String? date;
  double? accuracy;
  int? fixQuality;
  double? pdop;
  int? numberOfSatellites;
  int? batteryPercentage;
  double? latitudeError;
  double? longitudeError;

  GNSSLocation({
    this.receiverType,
    this.latitude,
    this.longitude,
    this.latitudeDirection,
    this.longitudeDirection,
    this.altitude,
    this.utcOfPositionFix,
    this.date,
    this.accuracy,
    this.fixQuality,
    this.pdop,
    this.numberOfSatellites,
    this.batteryPercentage,
    this.latitudeError,
    this.longitudeError,
  });
}

enum DeviceType { internalGPS, trimble, externalAccessory }

enum GNSSLocationDataKeys {
  receiverType,
  latitude,
  longitude,
  latitudeDirection,
  longitudeDirection,
  altitude,
  utcOfPositionFix,
  date,
  accuracy,
  fixQuality,
  pdop,
  numberOfSatellites,
  batteryPercentage,
  latitudeError,
  longitudeError,
}
