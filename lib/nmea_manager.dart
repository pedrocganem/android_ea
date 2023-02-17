// ignore_for_file: constant_identifier_names

import 'package:android_ea/gnss_location.dart';

enum NMEATypes {
  GPGNS, // https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_GNS.html
  GPGGA, // https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_GGA.html
  GPGSA, // https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_GSA.html
  GPRMC, // https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_RMC.html
  GPGST, // https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_GST.html
  GPRRE, // Unused https://www.hemispheregnss.com/technical-resource-manual/Import_Folder/GPRRE_Message.htm
  GPGSV, // Unused https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_GSV.html
  GPVTG, // Unused https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_VTG.html
  GAGSV, // Unused
  GLGSV, // Unused
  GBGSV, // Unused
  PJSI, // Geode Battery
}

/// $GPGST,172814.0,0.006,0.023,0.020,273.6,0.023,0.020,0.031*6A
enum GPGST {
  type(0),
  utcOfPositionFix(1),
  rmsValue(2),
  errorEllipseSemiMajor(3),
  errorEllipseSemiMajor2(4),
  errorEllipseOrientation(5),
  latitudeSigmaError(6),
  longitudeSigmaError(7),
  heightSigmaError(8),
  checksum(9);

  final int position;
  const GPGST(this.position);
}

// MARK: - GPGNS
/// https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_GNS.html
///
/// $GPGNS,014035.00,,,,,,8,,,,1.0,23*76
enum GPGNS {
  type(0),
  utcOfPositionFix(1),
  latitude(2),
  latitudeDirection(3),
  longitude(4),
  longitudeDirection(5),
  modeIndicator(6),
  numberOfSatellitesInUse(7),
  hdop(8),
  orthometricHeightMSL(9),
  geoidSeparation(10),
  ageOfDifferentialGPSData(11),
  referenceStationID(12),
  checksum(13);

  final int position;
  const GPGNS(this.position);
}

// MARK: - GPGGA
/// Time, position, and fix related data
/// https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_GGA.html
///
/// $GPGGA,172814.0,3723.46587704,N,12202.26957864,W,2,6,1.2,18.893,M,-25.669,M,2.0,0031*4F
enum GPGGA {
  type(0),
  utcOfPositionFix(1),
  latitude(2),
  latitudeDirection(3),
  longitude(4),
  longitudeDirection(5),
  gpsQualityIndicator(6),
  numberOfSatellitesInUse(7),
  hdop(8),
  orthometricHeightMSL(9),
  orthometricHeightMSLUnitOfMeasure(10),
  geoidSeparation(11),
  geoidSeparationUnitOfMeasure(12),
  ageOfDifferentialGPSData(13),
  referenceStationID(14);

  final int position;
  const GPGGA(this.position);
}

// MARK: - GPRMC
/// Position, velocity, and time
/// https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_RMC.html
///
/// $GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A
enum GPRMC {
  type(0),
  utcOfPositionFix(1),
  status(2),
  latitude(3),
  latitudeDirection(4),
  longitude(5),
  longitudeDirection(6),
  speed(7),
  trackAngle(8),
  date(9),
  magneticVariation(10),
  checksum(11);

  final int position;
  const GPRMC(this.position);
}

// MARK: - GPGSA
/// GPS DOP and active satellites
/// https://www.trimble.com/OEM_ReceiverHelp/V4.44/en/NMEA-0183messages_GSA.html
///
/// $GPGSA,M,3,07,08,09,11,27,28,30,,,,,,1.3,0.6,1.2,1*2E
/// $GPGSA,<1>,<2>,<3>,<3>,,,,,<3>,<3>,<3>,<4>,<5>,<6>*<7><CR><LF>
enum GPGSA {
  type(0),
  mode(1),
  fixType(2),
  prnNumber(3),
  pdop(15),
  hdop(16),
  vdop(17);
  // checksum(18);

  final int position;
  const GPGSA(this.position);
}

enum GPGSV {
  type(0),
  totalMessages(1),
  messageNumber(2),
  satellitesInView(3),
  satelliteNumber(4),
  elevation(5),
  azimuth(6),
  snr(7),
  checksum(8);

  final int position;
  const GPGSV(this.position);
}

class NmeaRawParser {
  GNSSLocation? formatMessage(String message) {
    var parameters = message.split(',');
    var type = parameters[0];
    switch (type) {
      case '\$GPGNS':
        if (parameters.length < 10) {
          return null;
        }
        return _formatGPGNS(parameters);
      case '\$GPGGA':
        if (parameters.length < 10) {
          return null;
        }
        return _formatGPGGA(parameters);
      case '\$GPGSA':
        if (parameters.length < 10) {
          return null;
        }
        return _formatGPGSA(parameters);
      case '\$GPRMC':
        if (parameters.length < 10) {
          return null;
        }
        return _formatGPRMC(parameters);
      case '\$GPGST':
        if (parameters.length < 10) {
          return null;
        }
        return _formatGPGST(parameters);
      case '\$GPGSV':
        if (parameters.length < 10) {
          return null;
        }
        return _formatGPGSV(parameters);
      default:
        return null;
    }
  }

  GNSSLocation _formatGPGST(List<String> parameters) {
    var type = parameters[GPGST.type.position];
    var utcOfPositionFix = parameters[GPGST.utcOfPositionFix.position];
    var rmsValue = parameters[GPGST.rmsValue.position];
    var errorEllipseSemiMajor =
        parameters[GPGST.errorEllipseSemiMajor.position];
    var errorEllipseSemiMajor2 =
        parameters[GPGST.errorEllipseSemiMajor2.position];
    var errorEllipseOrientation =
        parameters[GPGST.errorEllipseOrientation.position];
    var latitudeSigmaError = parameters[GPGST.latitudeSigmaError.position];
    var longitudeSigmaError = parameters[GPGST.longitudeSigmaError.position];
    var heightSigmaError = parameters[GPGST.heightSigmaError.position];
    var checksum = parameters[GPGST.checksum.position];
    final returnMessage =
        'type: $type, utcOfPositionFix: $utcOfPositionFix, rmsValue: $rmsValue, errorEllipseSemiMajor: $errorEllipseSemiMajor, errorEllipseSemiMajor2: $errorEllipseSemiMajor2, errorEllipseOrientation: $errorEllipseOrientation, latitudeSigmaError: $latitudeSigmaError, longitudeSigmaError: $longitudeSigmaError, heightSigmaError: $heightSigmaError, checksum: $checksum';
    return GNSSLocation();
  }

  GNSSLocation _formatGPGNS(List<String> parameters) {
    var type = parameters[GPGNS.type.position];
    var utcOfPositionFix = parameters[GPGNS.utcOfPositionFix.position];
    var latitude = parameters[GPGNS.latitude.position];
    var latitudeDirection = parameters[GPGNS.latitudeDirection.position];
    var longitude = parameters[GPGNS.longitude.position];
    var longitudeDirection = parameters[GPGNS.longitudeDirection.position];
    var modeIndicator = parameters[GPGNS.modeIndicator.position];
    var numberOfSatellitesInUse =
        parameters[GPGNS.numberOfSatellitesInUse.position];
    var hdop = parameters[GPGNS.hdop.position];
    var orthometricHeightMSL = parameters[GPGNS.orthometricHeightMSL.position];
    var geoidSeparation = parameters[GPGNS.geoidSeparation.position];
    var ageOfDifferentialGPSData =
        parameters[GPGNS.ageOfDifferentialGPSData.position];
    var referenceStationID = parameters[GPGNS.referenceStationID.position];
    var checksum = parameters[GPGNS.checksum.position];

    return GNSSLocation(
      receiverType: type,
      utcOfPositionFix: utcOfPositionFix,
      latitude: double.tryParse(latitude),
      longitude: double.tryParse(longitude),
      numberOfSatellites: int.tryParse(numberOfSatellitesInUse),
      pdop: double.tryParse(hdop),
      altitude: double.tryParse(orthometricHeightMSL),
    );
  }

  GNSSLocation _formatGPGGA(List<String> parameters) {
    var type = parameters[GPGGA.type.position];
    var utcOfPositionFix = parameters[GPGGA.utcOfPositionFix.position];
    var latitude = parameters[GPGGA.latitude.position];
    var latitudeDirection = parameters[GPGGA.latitudeDirection.position];
    var longitude = parameters[GPGGA.longitude.position];
    var longitudeDirection = parameters[GPGGA.longitudeDirection.position];
    var gpsQualityIndicator = parameters[GPGGA.gpsQualityIndicator.position];
    var numberOfSatellitesInUse =
        parameters[GPGGA.numberOfSatellitesInUse.position];
    var hdop = parameters[GPGGA.hdop.position];
    var orthometricHeightMSL = parameters[GPGGA.orthometricHeightMSL.position];
    var orthometricHeightMSLUnitOfMeasure =
        parameters[GPGGA.orthometricHeightMSLUnitOfMeasure.position];
    var geoidSeparation = parameters[GPGGA.geoidSeparation.position];
    var geoidSeparationUnitOfMeasure =
        parameters[GPGGA.geoidSeparationUnitOfMeasure.position];
    var ageOfDifferentialGPSData =
        parameters[GPGGA.ageOfDifferentialGPSData.position];
    var referenceStationID = parameters[GPGGA.referenceStationID.position];

    return GNSSLocation(
      receiverType: type,
      utcOfPositionFix: utcOfPositionFix,
      latitude: double.tryParse(latitude),
      longitude: double.tryParse(longitude),
      altitude: double.tryParse(orthometricHeightMSL),
      latitudeDirection: latitudeDirection,
      longitudeDirection: longitudeDirection,
      numberOfSatellites: int.tryParse(numberOfSatellitesInUse),
      fixQuality: int.tryParse(gpsQualityIndicator),
    );
  }

  GNSSLocation _formatGPGSA(List<String> parameters) {
    var type = parameters[GPGSA.type.position];
    var mode = parameters[GPGSA.mode.position];
    var fixType = parameters[GPGSA.fixType.position];
    var prnNumber = parameters[GPGSA.prnNumber.position];
    var pdop = parameters[GPGSA.pdop.position];
    var hdop = parameters[GPGSA.hdop.position];
    var vdop = parameters[GPGSA.vdop.position];
    // var checksum = parameters[GPGSA.checksum.position];

    return GNSSLocation(
      receiverType: type,
      pdop: double.tryParse(pdop),
    );
  }

  GNSSLocation _formatGPRMC(List<String> parameters) {
    var type = parameters[GPRMC.type.position];
    var utcOfPositionFix = parameters[GPRMC.utcOfPositionFix.position];
    var status = parameters[GPRMC.status.position];
    var latitude = parameters[GPRMC.latitude.position];
    var latitudeDirection = parameters[GPRMC.latitudeDirection.position];
    var longitude = parameters[GPRMC.longitude.position];
    var longitudeDirection = parameters[GPRMC.longitudeDirection.position];
    var speed = parameters[GPRMC.speed.position];
    var trackAngle = parameters[GPRMC.trackAngle.position];
    var date = parameters[GPRMC.date.position];
    var magneticVariation = parameters[GPRMC.magneticVariation.position];
    var checksum = parameters[GPRMC.checksum.position];

    return GNSSLocation(
      receiverType: type,
      utcOfPositionFix: utcOfPositionFix,
      latitude: double.tryParse(latitude),
      longitude: double.tryParse(longitude),
      latitudeDirection: latitudeDirection,
      longitudeDirection: longitudeDirection,
      date: date,
    );
  }

  GNSSLocation _formatGPGSV(List<String> parameters) {
    var type = parameters[GPGSV.type.position];
    var numberOfMessages = parameters[GPGSV.totalMessages.position];
    var messageNumber = parameters[GPGSV.messageNumber.position];
    var satellitesInView = parameters[GPGSV.satellitesInView.position];
    var satelliteNumber = parameters[GPGSV.satelliteNumber.position];
    var elevation = parameters[GPGSV.elevation.position];
    var azimuth = parameters[GPGSV.azimuth.position];
    var snr = parameters[GPGSV.snr.position];
    var checksum = parameters[GPGSV.checksum.position];

    return GNSSLocation(
      receiverType: type,
      numberOfSatellites: int.tryParse(satelliteNumber),
    );
  }
}
