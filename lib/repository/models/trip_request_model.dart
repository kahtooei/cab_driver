import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripRequestModel {
  String? requestToken;
  String? userId;
  String? pickupLocation;
  String? destinationLocation;
  String? paymentMethod;
  String? riderName;
  LatLng? pickupCoordinate;
  LatLng? destinationCoordinate;

  TripRequestModel(
      {this.requestToken,
      this.userId,
      this.pickupLocation,
      this.destinationLocation,
      this.paymentMethod,
      this.riderName,
      this.pickupCoordinate,
      this.destinationCoordinate});
}
