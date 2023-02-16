class NmeaEntity {
  String? messageType;
  double? latitude;
  String? latitudeDirection;
  double? longitude;
  String? longitudeDirection;
  int? fixQuality;
  int? satellites;
  double? hdop;
  double? altitude;
  double? geoidSeparation;

  NmeaEntity({
    this.messageType,
    this.latitude,
    this.latitudeDirection,
    this.longitude,
    this.longitudeDirection,
    this.fixQuality,
    this.satellites,
    this.hdop,
    this.altitude,
    this.geoidSeparation,
  });

  static NmeaEntity? fromNMEA(String nmeaString) {
    RegExp regExp = RegExp(
        r'\$(GPGGA),(\d+\.\d+),([NS]),(\d+\.\d+),([EW]),(\d),(\d+),(\d+\.\d+),(-?\d+\.\d+),M,(-?\d+\.\d+),M,,\*.{2}');
    Match? match = regExp.firstMatch(nmeaString);

    if (match == null) {
      return null;
    }

    return NmeaEntity(
      messageType: match.group(1),
      latitude: double.tryParse(match.group(2) ?? ''),
      latitudeDirection: match.group(3),
      longitude: double.tryParse(match.group(4) ?? ''),
      longitudeDirection: match.group(5),
      fixQuality: int.tryParse(match.group(6) ?? ''),
      satellites: int.tryParse(match.group(7) ?? ''),
      hdop: double.tryParse(match.group(8) ?? ''),
      altitude: double.tryParse(match.group(9) ?? ''),
      geoidSeparation: double.tryParse(match.group(10) ?? ''),
    );
  }

  NmeaEntity copyWith({
    String? messageType,
    double? latitude,
    String? latitudeDirection,
    double? longitude,
    String? longitudeDirection,
    int? fixQuality,
    int? satellites,
    double? hdop,
    double? altitude,
    double? geoidSeparation,
  }) {
    return NmeaEntity(
      messageType: messageType ?? this.messageType,
      latitude: latitude ?? this.latitude,
      latitudeDirection: latitudeDirection ?? this.latitudeDirection,
      longitude: longitude ?? this.longitude,
      longitudeDirection: longitudeDirection ?? this.longitudeDirection,
      fixQuality: fixQuality ?? this.fixQuality,
      satellites: satellites ?? this.satellites,
      hdop: hdop ?? this.hdop,
      altitude: altitude ?? this.altitude,
      geoidSeparation: geoidSeparation ?? this.geoidSeparation,
    );
  }
}
