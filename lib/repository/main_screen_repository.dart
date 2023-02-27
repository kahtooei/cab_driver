import 'dart:convert';

import 'package:cab_driver/data/remote/directions_api.dart';
import 'package:cab_driver/data/remote/geocoding.dart';
import 'package:cab_driver/data/remote/places_api.dart';
import 'package:cab_driver/repository/models/address.dart';
import 'package:cab_driver/repository/models/direction.dart';
import 'package:cab_driver/repository/models/prediction.dart';
import 'package:cab_driver/shared/resources/request_status.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainScreenRepository {
  GoogleGeoCoding geoCoding;
  GooglePlaceAPI placeAPI;
  GoogleDirectionsAPI directionsAPI;
  MainScreenRepository(this.geoCoding, this.placeAPI, this.directionsAPI);

  Future<RequestStatus<AddressModel>> getAddressWithPosition(
      double longitude, double latitude) async {
    try {
      var res = await geoCoding.getAddressWithPosition(latitude, longitude);
      if (res == '') {
        return FailedRequest<AddressModel>('request error');
      } else {
        Map data = jsonDecode(res);
        AddressModel address = AddressModel();
        address.latitude = latitude;
        address.longitude = longitude;
        address.placeFormattedAddress = data['results'][0]['formatted_address'];
        address.placeId = data['results'][0]['place_id'];
        return SuccessRequest<AddressModel>(address);
      }
    } catch (e) {
      return FailedRequest<AddressModel>(e.toString());
    }
  }

  Future<RequestStatus<AddressModel>> getPositionWithAddress(
      String address) async {
    try {
      var res = await geoCoding.getPositionWithAddress(address);
      if (res == '') {
        return FailedRequest<AddressModel>('request error');
      } else {
        Map data = jsonDecode(res);
        AddressModel address = AddressModel();
        address.latitude = data['results'][0]['geometry']['location']['lat'];
        address.longitude = data['results'][0]['geometry']['location']['lng'];
        address.placeFormattedAddress = data['results'][0]['formatted_address'];
        address.placeId = data['results'][0]['place_id'];
        return SuccessRequest<AddressModel>(address);
      }
    } catch (e) {
      return FailedRequest<AddressModel>(e.toString());
    }
  }

  Future<RequestStatus<List<PredictionModel>>> getPredictionPlaces(
      String name) async {
    try {
      var res = await placeAPI.getPrediction(name);
      if (res == '') {
        return FailedRequest<List<PredictionModel>>('request error');
      } else {
        Map data = jsonDecode(res);
        List<PredictionModel> predictionList = [];
        for (Map<String, dynamic> item in data['predictions']) {
          predictionList.add(PredictionModel.fromJson(item));
        }
        return SuccessRequest<List<PredictionModel>>(predictionList);
      }
    } catch (e) {
      return FailedRequest<List<PredictionModel>>(e.toString());
    }
  }

  Future<RequestStatus<AddressModel>> getPlaceDetails(String placeId) async {
    try {
      var res = await placeAPI.getPlaceDetails(placeId);
      if (res == '') {
        return FailedRequest<AddressModel>('request error');
      } else {
        Map data = jsonDecode(res);
        AddressModel placeDetails = AddressModel();
        placeDetails.placeId = placeId;
        placeDetails.placeFormattedAddress =
            data['result']['formatted_address'];
        placeDetails.placeName = data['result']['name'];
        placeDetails.latitude = data['result']['geometry']['location']['lat'];
        placeDetails.longitude = data['result']['geometry']['location']['lng'];
        return SuccessRequest<AddressModel>(placeDetails);
      }
    } catch (e) {
      return FailedRequest<AddressModel>(e.toString());
    }
  }

  Future<RequestStatus<DirectionModel>> getDirections(
      LatLng startPosition, LatLng endPosition) async {
    try {
      var res = await directionsAPI.getDirections(startPosition, endPosition);
      if (res == '') {
        return FailedRequest<DirectionModel>('request error');
      } else {
        Map data = jsonDecode(res);
        DirectionModel direction = DirectionModel();
        direction.distanceText =
            data['routes'][0]['legs'][0]['distance']['text'];
        direction.distanceValue =
            data['routes'][0]['legs'][0]['distance']['value'];
        direction.durationText =
            data['routes'][0]['legs'][0]['duration']['text'];
        direction.durationValue =
            data['routes'][0]['legs'][0]['duration']['value'];
        direction.encodedPoints =
            data['routes'][0]['overview_polyline']['points'];

        return SuccessRequest<DirectionModel>(direction);
      }
    } catch (e) {
      return FailedRequest<DirectionModel>(e.toString());
    }
  }
}
