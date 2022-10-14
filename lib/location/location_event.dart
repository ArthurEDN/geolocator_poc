part of 'location_bloc.dart';

abstract class LocationEvent {}

class LocationStarted extends LocationEvent {}

class LocationChanged extends LocationEvent {
  final Position position;

  LocationChanged({required this.position});
}

class LocationErrorEvent extends LocationEvent {
  final String message;

  LocationErrorEvent({required this.message});
}
