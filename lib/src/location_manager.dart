/// The LocationManager class in Dart provides methods for fetching address components based on GPS
/// coordinates, addresses, and managing location permissions.
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationManager extends ChangeNotifier {
  LocationManager._i();

  static LocationManager i = LocationManager._i();

  factory LocationManager() => i;

  /// The function `getAddressFromGPS` retrieves address information based on the current GPS location.
  ///
  /// Returns:
  ///   The `getAddressFromGPS` function returns a `Future<AddressComponent?>`. This means it returns a
  /// future that may contain an `AddressComponent` object or be `null`.
  Future<AddressComponent?> getAddressFromGPS() async {
    try {
      bool hasPermission = await _checkAndRequestLocationPermission();
      if (!hasPermission) {
        Permission.location.request();
        return null;
      }

      Position position = await _getCurrentPosition();
      List<Placemark> placemarks = await _getPlacemarks(position);

      AddressComponent addressComponent =
          _createAddressComponent(position, placemarks.first);

      return addressComponent;
    } catch (e) {
      throw Exception(e);
    }
  }

  /// The function `getAddressFromCoordinates` retrieves address components based on latitude and
  /// longitude coordinates.
  ///
  /// Args:
  ///   lat (double): Latitude coordinate of the location.
  ///   long (double): The `long` parameter in the `getAddressFromCoordinates` function represents the
  /// longitude coordinate of a location. Longitude is a geographic coordinate that specifies the
  /// east-west position of a point on the Earth's surface. It is measured in degrees, with values ranging
  /// from -180 degrees (west) to +
  ///
  /// Returns:
  ///   The function `getAddressFromCoordinates` is returning a `Future<AddressComponent?>`.
  Future<AddressComponent?> getAddressFromCoordinates({
    required double lat,
    required double long,
  }) async {
    try {
      bool hasPermission = await _checkAndRequestLocationPermission();
      if (!hasPermission) {
        Permission.location.request();
        return null;
      }

      final position = Position(
        longitude: lat,
        latitude: long,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      List<Placemark> placemarks = await _getPlacemarks(position);

      AddressComponent addressComponent =
          _createAddressComponent(position, placemarks.first);

      return addressComponent;
    } catch (e) {
      throw Exception(e);
    }
  }

  /// The `decodeAddress` function decodes an address into an `AddressComponent` by retrieving location
  /// and placemark information asynchronously.
  ///
  /// Args:
  ///   address (String): The `decodeAddress` function takes a `String` parameter `address` which
  /// represents the address that needs to be decoded into an `AddressComponent`. The function uses the
  /// `locationFromAddress` and `placemarkFromCoordinates` functions to retrieve the location and
  /// placemark information based on the provided address
  ///
  /// Returns:
  ///   A `Future<AddressComponent>` is being returned from the `decodeAddress` function.
  Future<AddressComponent> decodeAddress({required String address}) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      List<Placemark> placemarks = await placemarkFromCoordinates(
        locations.first.latitude,
        locations.first.longitude,
      );

      return _createAddressComponent(
        Position(
          latitude: locations.first.latitude,
          longitude: locations.first.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
        placemarks.first,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _checkAndRequestLocationPermission() async {
    if (await Permission.location.isGranted) return true;

    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      Geolocator.openLocationSettings();
      return await Permission.location.status == PermissionStatus.granted;
    }

    _showLocationSettingsToast();
    return false;
  }

  void _showLocationSettingsToast() {
    Fluttertoast.showToast(
      msg: 'Enable location permission for better experience.',
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Future<Position> _getCurrentPosition() async {
    final LocationSettings? locationSettings;

    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
      );
    } else {
      throw Exception('Location for this platform is unimplemented');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  Future<List<Placemark>> _getPlacemarks(Position position) async {
    return await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
  }

  AddressComponent _createAddressComponent(
      Position position, Placemark placemark) {
    return AddressComponent(
      address1: placemark.street ?? '',
      address2: placemark.thoroughfare ?? '',
      state: placemark.administrativeArea ?? '',
      country: placemark.country ?? '',
      city: placemark.locality ?? '',
      postalCode: placemark.postalCode ?? '',
      latitude: position.latitude.toString(),
      longitude: position.longitude.toString(),
      countryCode: placemark.isoCountryCode ?? '',
    );
  }

/// The function `getAddressWithDistance` calculates the distance between a list of addresses and the
/// current location, returning a map of address components with their corresponding distances sorted in
/// ascending order.
/// 
/// Args:
///   addresses (List<AddressComponent>): The `getAddressWithDistance` function you provided seems to
/// calculate the distance between a list of addresses and the current location. However, there are a
/// couple of issues in the code that need to be addressed:
/// 
/// Returns:
///   The `getAddressWithDistance` function returns a `Future` that resolves to a `Map` where the keys
/// are `AddressComponent` objects and the values are `double` values representing the distance between
/// each address in the input list and the current location. The distances are calculated in kilometers.
  Future<Map<AddressComponent, double>> getAddressWithDistance(
      List<AddressComponent> addresses) async {
    final myLoc = await _getCurrentPosition();

    Map<AddressComponent, double> addressDistanceMap = {};

    if (addresses.isNotEmpty) {
      for (int i = 0; i < addresses.length; i++) {
        final locA = LatLong(
          lat: double.parse(addresses[i].latitude),
          long: double.parse(addresses[i].longitude),
        );
        final locB = LatLong(
          lat: myLoc.latitude,
          long: myLoc.latitude,
        );

        final distance =
            _distanceBetween(latLongA: locA, latLongB: locB); //Distance in KM's

        Map<AddressComponent, double> addressWithDist = {
          addresses[i]!: distance
        };

        addressDistanceMap.addAll(addressWithDist);

        final sortedAddressDistance = addressDistanceMap.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        addressDistanceMap.clear();

        addressDistanceMap.addEntries(sortedAddressDistance);
      }
    }

    return addressDistanceMap;
  }

/// The `_distanceBetween` function calculates the distance between two geographical coordinates using
/// the Haversine formula in Dart.
/// 
/// Args:
///   latLongA (LatLong): The `latLongA` parameter represents the latitude and longitude coordinates of
/// the first location. It is of type `LatLong`, which likely contains the latitude and longitude values
/// for a specific point on Earth.
///   latLongB (LatLong): It seems like you were about to provide some information about the `latLongB`
/// parameter but it got cut off. Could you please provide the latitude and longitude values for
/// `latLongB` so I can help you calculate the distance between the two points using the Haversine
/// formula?
/// 
/// Returns:
///   The function `_distanceBetween` calculates and returns the distance in kilometers between two
/// geographical points represented by the `LatLong` objects `latLongA` and `latLongB`.
  double _distanceBetween(
      {required LatLong latLongA, required LatLong latLongB}) {
    const earthRadius = 6371; // Radius of the Earth in kilometers

    // Convert degrees to radians
    double radLat1 = _degreeToRadian(latLongA.lat!);
    double radLon1 = _degreeToRadian(latLongA.long!);
    double radLat2 = _degreeToRadian(latLongB.lat!);
    double radLon2 = _degreeToRadian(latLongB.long!);

    // Haversine formula
    double dLat = radLat2 - radLat1;
    double dLon = radLon2 - radLon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radLat1) * cos(radLat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c; // Distance in kilometers
    return distance;
  }

/// The `_degreeToRadian` function converts degrees to radians in Dart.
/// 
/// Args:
///   degree (double): The `degree` parameter represents an angle measurement in degrees that you want
/// to convert to radians.
/// 
/// Returns:
///   The function `_degreeToRadian` is returning the value of `degree` converted from degrees to
/// radians.
  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }
}

/// The AddressComponent class in Dart represents a structured address with various components like
/// address lines, country, state, city, postal code, latitude, longitude, and country code.
class AddressComponent {
  String address1;
  String address2;
  String country;
  String state;
  String city;
  String postalCode;
  String latitude;
  String longitude;
  String countryCode;

  AddressComponent({
    required this.address1,
    required this.address2,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.countryCode,
  });
}

/// The `LatLong` class in Dart represents latitude and longitude coordinates with nullable double
/// values.
class LatLong {
  double? lat;
  double? long;

  LatLong({required this.lat, required this.long});
}
