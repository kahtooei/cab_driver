import 'package:bloc/bloc.dart';
import 'package:cab_driver/bloc/main_screen_bloc/main_screen_status.dart';
import 'package:cab_driver/repository/main_screen_repository.dart';
import 'package:cab_driver/shared/resources/request_status.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'main_screen_event.dart';
part 'main_screen_state.dart';

class MainScreenBloc extends Bloc<MainScreenEvent, MainScreenState> {
  MainScreenRepository mainScreenRepository;
  MainScreenBloc(this.mainScreenRepository)
      : super(MainScreenState(
          currentPosition: const LatLng(37.42796133580664, -122.085749655962),
          predictionsList: CompletePredictionsStatus([]),
          routeDirection: EmptyDirectionsStatus(),
        )) {
    //update current address
    on<UpdateCurrentAddressEvent>((event, emit) async {
      emit(state.copyWith(
          current_position: LatLng(event.latitude, event.longitude)));
    });

    //get predictions
    on<GetPredictionsListEvent>((event, emit) async {
      emit(state.copyWith(predictions_list: LoadingPredictionsStatus()));
      RequestStatus request =
          await mainScreenRepository.getPredictionPlaces(event.name);
      if (request is SuccessRequest) {
        emit(state.copyWith(
            predictions_list: CompletePredictionsStatus(request.response)));
      } else {
        emit(state.copyWith(
            predictions_list: FailedPredictionsStatus(request.error!)));
      }
    });

    //get directions for start and end positions
    on<GetRouteDirectionEvent>((event, emit) async {
      emit(state.copyWith(route_direction: LoadingDirectionsStatus()));
      RequestStatus request = await mainScreenRepository.getDirections(
          event.startPosition, event.endPosition);
      if (request is SuccessRequest) {
        emit(state.copyWith(
            route_direction: CompleteDirectionsStatus(request.response)));
      } else {
        emit(state.copyWith(
            route_direction: FailedDirectionsStatus(request.error!)));
      }
    });

    //reset app after click arrow back button
    on<ResetAppEvent>((event, emit) async {
      emit(state.copyWith(
        current_position: const LatLng(37.42796133580664, -122.085749655962),
        predictions_list: CompletePredictionsStatus([]),
        route_direction: EmptyDirectionsStatus(),
      ));
    });
  }
}
