part of 'location_bloc.dart';


abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoadInProgress extends LocationState {}

class LocationLoadSuccessState extends LocationState {
  final Position position;

  LocationLoadSuccessState({required this.position});
}

class LocationErrorState extends LocationState {
  final String message;

  LocationErrorState({required this.message});
}
