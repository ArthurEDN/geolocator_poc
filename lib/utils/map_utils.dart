import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_poc/utils/GeolocatorWrapper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class GoogleMapUtils{
  GeolocatorWrapper geolocatorWrapper = GeolocatorWrapper();
  static final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  static late LocationSettings locationSettings;
  static final _positionController = StreamController<Position>.broadcast();
  // static final _errorController = StreamController<LocationError>.broadcast();
  static late StreamSubscription? _locationSubscription;
  static late StreamSubscription? _serviceSubscription;

  static Stream<Position> get position => _positionController.stream.asBroadcastStream();
  //static Stream<LocationError> get error => _errorController.stream.asBroadcastStream();


  static Future<void> initializeConfigurations() async {
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        useMSLAltitude: true,
      );
    } else {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: false,
      );
    }
  }

  static Future<void> startLocationUpdate() async{
    try{
       await checkLocationPermissions();
       bool locationServiceStatus = await isLocationServiceEnabled();
         _serviceSubscription = _geolocatorPlatform.getServiceStatusStream()
           .listen((ServiceStatus serviceStatus) {
               if(serviceStatus.name == "enabled" ){
                 _locationSubscription = _geolocatorPlatform.getPositionStream(locationSettings: locationSettings)
                   .listen((Position? position) async {
                   print(position.toString());
                     if (position != null) {
                       _positionController.sink.add(position);
                     }
                 },
                  cancelOnError: false,
                 );
               }
               if(serviceStatus.name == "disabled"){
                 _positionController.sink.addError(const LocationServiceDisabledException());
               }
           },
       );
    }catch(e){
      rethrow;
    }
  }

  static Future<LatLng> getMyLocation() async {
    try {
      Position userPosition = await position.first;
      return LatLng(userPosition.latitude, userPosition.longitude);
    } on LocationServiceDisabledException{
      throw const LocationServiceDisabledException();
    } on TimeoutException {
      throw TimeoutException("Sem conexão com a internet. As informações podem estar desatualizadas");
    } catch(e){
      rethrow;
    }
  }

  static Future goToLocation(Completer<GoogleMapController> mapsController, LatLng localizacao, double zoom) async {
    final GoogleMapController controller = await mapsController.future;
    try{
      await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(localizacao.latitude, localizacao.longitude),
        tilt: 32,
        zoom: zoom,
      )));
    } catch(e){
      await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: const LatLng(-3.768964, -38.478966),
          zoom: zoom,
          tilt: 32
      )));
      rethrow;
    }
  }

  static goToMyLocation(Completer<GoogleMapController> mapsController) async {
    final GoogleMapController controller = await mapsController.future;
    try{
      await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: await getMyLocation(),
        tilt: 32,
        zoom: 18,
      )));
    } catch(e){
      rethrow;
    }
  }

  static Future goToLocationAfterMakeRoute(
      Completer<GoogleMapController> mapsController,
      LatLng targetPosition,
      double zoom,
      ) async {
    final GoogleMapController controller = await mapsController.future;
    try{
      LatLng userPosition = await getMyLocation();
      await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: userPosition,
        tilt: 32,
        bearing: Geolocator.bearingBetween(
            userPosition.latitude,
            userPosition.longitude,
            targetPosition.latitude,
            targetPosition.longitude),
        zoom: zoom,
      )));
    } catch(e){
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: const LatLng(-3.768964, -38.478966),
          zoom: zoom,
          tilt: 32
      )));
      rethrow;
    }
  }

  static Future<void> showMarkerInfoWindow(Completer<GoogleMapController> mapsController, String markerId) async{
    final GoogleMapController controller = await mapsController.future;
    try{
      await controller.showMarkerInfoWindow(MarkerId(markerId));
    } on PlatformException {
      throw PlatformException(code: "404", message: "Ocorreu um erro inesperado", stacktrace: StackTrace.current.toString());
    }
  }

  static Future<void> hideMarkerInfoWindow(Completer<GoogleMapController> mapsController, String markerId) async{
    final GoogleMapController controller = await mapsController.future;
    try{
      if(await controller.isMarkerInfoWindowShown(MarkerId(markerId))){
        await controller.hideMarkerInfoWindow(MarkerId(markerId));
      }
    } on PlatformException {
      throw PlatformException(code: "404", message: "Ocorreu um erro inesperado", stacktrace: StackTrace.current.toString());
    }
  }

  static Future<bool> isLocationServiceEnabled() async{
    bool servicoAtivado = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!servicoAtivado) {
      throw const LocationServiceDisabledException();
    }
    return servicoAtivado;
  }

  static Future<void> checkLocationPermissions() async {
    LocationPermission permissao = await _geolocatorPlatform.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await _geolocatorPlatform.requestPermission();
      if (permissao == LocationPermission.denied) {
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }

  }

}
