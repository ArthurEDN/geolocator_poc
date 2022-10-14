import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  late StreamSubscription locationSubscription;
  final StreamController<LocationEvent> _locationController = StreamController<LocationEvent>.broadcast();
  Stream<LocationEvent> get locationStream => _locationController.stream.asBroadcastStream();

  LocationBloc() : super(LocationInitial()) {
    on<LocationEvent>((event, emit)
    async{
      if (event is LocationStarted) {
        emit(LocationLoadInProgress());
        await emit.onEach<Position>(
            Geolocator.getPositionStream(),
            onData: (position){
             add(LocationChanged(position: position));
             // _locationController.add(LocationChanged(position: position));
          },
          onError: (error, stacktrace){
            if(error.runtimeType == LocationServiceDisabledException || error == LocationServiceDisabledException){
              add(LocationErrorEvent(message: error.toString()));
            }
          }

        );
        // locationSubscription = Geolocator.getPositionStream().listen(
        //   (Position position) async {
        //     await emit.onEach<Position>(stream, onData: onData) add(LocationChanged(position: position));
        //     _locationController.add(LocationChanged(position: position));
        //   },
        // );
      }
      // else if (event is LocationChanged) {
      //     return await emit.forEach(locationStream, onData: (data){
      //      return LocationLoadSuccess(position: event.position);
      //   });
      // }
    });

    on<LocationChanged>((event, emit) => emit(LocationLoadSuccessState(position: event.position)));
    on<LocationErrorEvent>((event, emit) => emit(LocationErrorState(message: event.message)));

  }

  @override
  Future<void> close() {
    return super.close();
  }
}
