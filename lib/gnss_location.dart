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

  GNSSLocation merge(GNSSLocation oldData) {
    return GNSSLocation(
      receiverType: receiverType ?? oldData.receiverType,
      latitude: latitude ?? oldData.latitude,
      longitude: longitude ?? oldData.longitude,
      latitudeDirection: latitudeDirection ?? oldData.latitudeDirection,
      longitudeDirection: longitudeDirection ?? oldData.longitudeDirection,
      altitude: altitude ?? oldData.altitude,
      utcOfPositionFix: utcOfPositionFix ?? oldData.utcOfPositionFix,
      date: date ?? oldData.date,
      accuracy: accuracy ?? oldData.accuracy,
      fixQuality: fixQuality ?? oldData.fixQuality,
      pdop: pdop ?? oldData.pdop,
      numberOfSatellites: numberOfSatellites ?? oldData.numberOfSatellites,
      batteryPercentage: batteryPercentage ?? oldData.batteryPercentage,
      latitudeError: latitudeError ?? oldData.latitudeError,
      longitudeError: longitudeError ?? oldData.longitudeError,
    );
  }
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
