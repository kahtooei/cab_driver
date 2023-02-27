import 'package:cab_driver/bloc/main_screen_bloc/main_screen_bloc.dart';
import 'package:cab_driver/data/remote/directions_api.dart';
import 'package:cab_driver/data/remote/geocoding.dart';
import 'package:cab_driver/data/remote/places_api.dart';
import 'package:cab_driver/repository/main_screen_repository.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

setUp() {
  //call remote api
  getIt.registerSingleton<GoogleGeoCoding>(GoogleGeoCoding());
  getIt.registerSingleton<GooglePlaceAPI>(GooglePlaceAPI());
  getIt.registerSingleton<GoogleDirectionsAPI>(GoogleDirectionsAPI());

  //repository
  getIt.registerSingleton<MainScreenRepository>(
      MainScreenRepository(getIt(), getIt(), getIt()));

  //bloc
  getIt.registerSingleton<MainScreenBloc>(MainScreenBloc(getIt()));
}
