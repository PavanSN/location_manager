# Location Manager

The `location_manager` package provides a comprehensive and easy-to-use solution for managing location-based services in Flutter applications. It allows developers to retrieve detailed address components based on GPS coordinates, latitude and longitude, or address strings, while effectively handling location permissions across Android and iOS platforms.

## Features

- **GPS-based Address Retrieval**: Retrieve detailed address information from the device's current GPS location, including street, city, state, country, and postal code.
- **Coordinate-based Address Retrieval**: Fetch address components from specified latitude and longitude coordinates.
- **Address Decoding**: Convert an address string into geographic coordinates and detailed address information.
- **Location Permissions Management**: Check and request location permissions, prompt users to enable location services, and handle different permission statuses effectively.
- **Cross-Platform Support**: Optimized location accuracy settings for both Android and iOS platforms.

## Installation

1. Import the Package

```dart
import 'package:location_manager/location_manager.dart';
```

2. Initialize the LocationManager

```dart
LocationManager locationManager = LocationManager();
```



```dart
AddressComponent? address = await locationManager.getAddressFromGPS();
if (address != null) {
  print("Address: ${address.address1}, ${address.city}, ${address.country}");
}
```

```dart
AddressComponent? address = await locationManager.getAddressFromGPS();
if (address != null) {
  print("Address: ${address.address1}, ${address.city}, ${address.country}");
}
```

```yaml
dependencies:
  location_manager: 
