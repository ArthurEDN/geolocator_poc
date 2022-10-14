import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GeolocatorWrapper {
  StreamController<Position>? _positionController;
  StreamController<bool>? _serviceEnabledController;
  StreamSubscription? _positionSubscription, _serviceEnabledSubscription;

  /// checa se o serviço de localização está ativado
  Future<bool> get isLocationServiceEnabled => Geolocator.isLocationServiceEnabled();

  ///Retorna um [Future] indicando se o usuário permite que o App acesse a localização do dispositivo.
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<bool> get hasPermission async {
    final status = await checkPermission();
    return status == LocationPermission.always || status == LocationPermission.whileInUse;
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<LocationPermission> requestPermission() => Geolocator.requestPermission();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Calcula o valor da distancia e do angulo entre dois pontos
  double bearing(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) =>
      Geolocator.bearingBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );

  /// retorna uma stream para escutar as mudanças nos status do GPS(ativado ou desativado)
  Stream<bool> get onServiceEnabled {
    _serviceEnabledController ??= StreamController.broadcast();

    // escuta as mudanças no serviço de GPS do aparelho
    _serviceEnabledSubscription = Geolocator.getServiceStatusStream().listen(
          (event) {
        final enabled = event == ServiceStatus.enabled;
        if (enabled) {
          _notifyServiceEnabled(true);
          if (_positionController != null) {
            _initLocationUpdates();
          }
        }
      },
    );

    return _serviceEnabledController!.stream;
  }

  /// returna uma stream que escuta a mudanças na localização
  Stream<Position> get onLocationUpdates {
    _positionController ??= StreamController.broadcast();
    _initLocationUpdates();
    return _positionController!.stream;
  }

  /// começa a escutar as mudanças da localização
  void _initLocationUpdates() async {
    await _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream().listen(
          (event) {
        _positionController?.sink.add(event);
      },
      onError: (e) {
        if (e is LocationServiceDisabledException) {
          _notifyServiceEnabled(false);
        }
      },
    );
  }

  /// notifica todos os listeners que o status do serviço de GPS mudou
  void _notifyServiceEnabled(bool enabled) {
    if (_serviceEnabledController != null) {
      _serviceEnabledController!.sink.add(enabled);
    }
  }

  /// retorna a localização atual
  Future<Position?> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.best,
    bool forceAndroidLocationManager = false,
    Duration? timeLimit,
  }) async {
    try {
      // getCurrentPosition lança uma exceção quando o serviço de localização está desabilitado
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: desiredAccuracy,
        forceAndroidLocationManager: forceAndroidLocationManager,
        timeLimit: timeLimit,
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  /// Retorna a última posição conhecida armazenada no dispositivo do usuário.
  Future<Position?> getLastKnowPosition({bool forceAndroidLocationManager = false}) async {
    return Geolocator.getLastKnownPosition(
      forceAndroidLocationManager: forceAndroidLocationManager,
    );
  }


  /// fecha todos os controladores e cancela todos as subscrições
  void dispose() {
    _positionController?.close();
    _serviceEnabledSubscription?.cancel();
    _serviceEnabledController?.close();
    _positionSubscription?.cancel();
  }
}
