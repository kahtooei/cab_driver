import 'package:cab_driver/repository/models/trip_request_model.dart';
import 'package:flutter/material.dart';

class AcceptedRequestPage extends StatelessWidget {
  final TripRequestModel trip;
  const AcceptedRequestPage(this.trip, {super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Trip Accepted"),
      ),
    );
  }
}
