part of 'main_screen_bloc.dart';

@immutable
class MainScreenState {
  final LatLng currentPosition;
  final PredictionsStatus predictionsList;
  final DirectionsStatus routeDirection;
  const MainScreenState({
    required this.currentPosition,
    required this.predictionsList,
    required this.routeDirection,
  });

  MainScreenState copyWith({
    LatLng? current_position,
    PredictionsStatus? predictions_list,
    DirectionsStatus? route_direction,
  }) {
    return MainScreenState(
      currentPosition: current_position ?? currentPosition,
      predictionsList: predictions_list ?? predictionsList,
      routeDirection: route_direction ?? routeDirection,
    );
  }
}
