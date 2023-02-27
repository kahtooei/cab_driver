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
          currentPosition: LoadingMainScreenStatus(),
          predictionsList: CompletePredictionsStatus([]),
          routeDirection: EmptyDirectionsStatus(),
        )) {
    //get current address
    on<GetCurrentAddressEvent>((event, emit) async {
      emit(state.copyWith(current_position: LoadingMainScreenStatus()));
      RequestStatus request = await mainScreenRepository.getAddressWithPosition(
          event.longitude, event.latitude);
      if (request is SuccessRequest) {
        emit(state.copyWith(
            current_position: CompleteMainScreenStatus(request.response)));
      } else {
        emit(state.copyWith(
            current_position: FailedMainScreenStatus(request.error!)));
      }
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
        current_position: LoadingMainScreenStatus(),
        predictions_list: CompletePredictionsStatus([]),
        route_direction: EmptyDirectionsStatus(),
      ));
    });
  }
}
