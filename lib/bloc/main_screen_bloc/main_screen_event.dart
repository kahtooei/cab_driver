part of 'main_screen_bloc.dart';

@immutable
abstract class MainScreenEvent {}

class UpdateCurrentAddressEvent extends MainScreenEvent {
  final double latitude;
  final double longitude;
  UpdateCurrentAddressEvent({required this.latitude, required this.longitude});
}

class GetPredictionsListEvent extends MainScreenEvent {
  final String name;
  GetPredictionsListEvent({required this.name});
}

class GetRouteDirectionEvent extends MainScreenEvent {
  final LatLng startPosition;
  final LatLng endPosition;
  GetRouteDirectionEvent(
      {required this.startPosition, required this.endPosition});
}

class ResetAppEvent extends MainScreenEvent {
  ResetAppEvent();
}
