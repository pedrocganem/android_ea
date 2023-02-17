// ignore_for_file: file_names

import 'dart:math';

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
  String? latPrefix;
  String? longPrefix;

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
    this.latPrefix = "",
    this.longPrefix = "",
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

  double calculateAccuracy(double latError, double longError) {
    final a = pow(longError, 2);
    final b = pow(latError, 2);
    final c = a + b;
    final d = sqrt(c);
    final accuracy = d.truncateToDouble();
    return accuracy;
  }

  GNSSLocation formatValues(GNSSLocation rawData) {
    var latitute = rawData.latitude;
    var latDirection = rawData.latitudeDirection;
    var longitude = rawData.longitude;
    var longDirection = rawData.longitudeDirection;
    var accuracy = 0.0;
    var latError = rawData.latitudeError;
    var longError = rawData.longitudeError;
    var latPrefix = rawData.latPrefix;
    var longPrefix = rawData.longPrefix;

    if (latitude != null && latDirection != null) {
      if (latitudeDirection == "S") {
        latPrefix = "-";
      } else {
        latPrefix = "";
      }
    }

    if (longitude != null && latDirection != null) {
      if (longitudeDirection == "W") {
        longPrefix = "-";
      } else {
        longPrefix = "";
      }
    }

    if (latError != null && longError != null) {
      accuracy = calculateAccuracy(latError, longError);
    }

    return GNSSLocation(
        receiverType: rawData.receiverType,
        latitude: latitute,
        longitude: longitude,
        latitudeDirection: latDirection,
        longitudeDirection: longDirection,
        altitude: rawData.altitude,
        utcOfPositionFix: rawData.utcOfPositionFix,
        date: rawData.date,
        accuracy: accuracy,
        fixQuality: rawData.fixQuality,
        pdop: rawData.pdop,
        numberOfSatellites: rawData.numberOfSatellites,
        batteryPercentage: rawData.batteryPercentage,
        latitudeError: latError,
        longitudeError: longError,
        latPrefix: latPrefix,
        longPrefix: longPrefix);
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
