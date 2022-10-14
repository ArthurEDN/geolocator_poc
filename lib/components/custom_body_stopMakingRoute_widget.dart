import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/map_utils.dart';


class CustomBodyStopMakingRouteBottomSheetWidget extends StatelessWidget {
  final String title;
  final LatLng locationToGo;
  final Function arrowBackOnPressedFunction;
  final Function buttonOnPressedFunction;

  const CustomBodyStopMakingRouteBottomSheetWidget({
    Key? key,
    required this.title,
    required this.locationToGo,
    required this.arrowBackOnPressedFunction,
    required this.buttonOnPressedFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height/3.5,
      child: StreamBuilder<Position>(
          initialData: const Position(longitude: -38.478966, latitude: -3.768964, timestamp: null, accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0) ,
          stream: GoogleMapUtils.position.asBroadcastStream(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              print(snapshot.data);
              return Column(
                children: [
                  const LinearProgressIndicator(),
                  const Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Text(
                      "Traçando sua rota",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: "Open Sans",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 32.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async => buttonOnPressedFunction(),
                          child: const Text(
                            "Cancelar",
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
            if(snapshot.hasData){
              print(snapshot.data);
              return Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 24.0),
                        child: IconButton(
                          iconSize: 32,
                          icon: const Icon(Icons.arrow_back_outlined),
                          color: const Color(0xFF005B9B),
                          onPressed: () async => arrowBackOnPressedFunction(),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24.0, right: 24),
                          child: Text(
                            "Caminho para $title",
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: "Open Sans",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 16.0, bottom: 2.0),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: Color(0xFFD3EBFF)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0 ,top: 6.0, bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.explore_outlined,
                              size: 36,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "Distância\n",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12.0,
                                          fontFamily: 'Open Sans'
                                      ),
                                    ),
                                    TextSpan(
                                      text:_metersOrKilometer(
                                        _getDistanceBetweenLocations(
                                            LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                                            locationToGo),),
                                      style: const TextStyle(
                                        color: Color(0xFF0088CC),
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Open Sans',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 24.0, left: 8.0),
                              child: ElevatedButton(
                                onPressed: () async => buttonOnPressedFunction(),
                                child: const Text(
                                  "Finalizar rota",
                                  style: TextStyle(
                                    fontFamily: "Open Sans",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            if(snapshot.hasError){
              if(snapshot.error.runtimeType == LocationServiceDisabledException){
                return BodyError(
                  errorMessageTitle: "Oops! Sua localização está desabilitada",
                  errorMessageSubTitle: "Por favor, habilite a localização no seu dispositivo e tente novamente mais tarde",
                  arrowBackOnPressedFunction: buttonOnPressedFunction,
                );
              }else if(snapshot.error.runtimeType == TimeoutException){
                return BodyError(
                  errorMessageTitle: "Oops! Sem conexão com a internet",
                  errorMessageSubTitle: "Sem internet. Por favor, verifique sua conexão e tente novamente",
                  arrowBackOnPressedFunction: buttonOnPressedFunction,
                );
              }else{
                return BodyError(
                  errorMessageTitle: "Ocorreu um erro.",
                  errorMessageSubTitle: "O serviço está indisponível. Por favor, tente novamente mais tarde",
                  arrowBackOnPressedFunction: buttonOnPressedFunction,
                );
              }
            }
            else {
              return Container();
            }
          }
      ),
    );
  }


  double _getDistanceBetweenLocations(LatLng userPosition, LatLng locationToGo){
    return Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      locationToGo.latitude,
      locationToGo.longitude,
    );
  }

  String _metersOrKilometer(double distance){

    if(distance >= 1000){
      double distanceInKilometer = distance/1000;
      return "${distanceInKilometer.toStringAsFixed(1)} km";
    }
    return "${distance.toStringAsFixed(0)} m";
  }
}

class BodyError extends StatelessWidget {
  final String errorMessageTitle;
  final String errorMessageSubTitle;
  final Function arrowBackOnPressedFunction;
  const BodyError({
    Key? key,
    required this.errorMessageTitle,
    required this.errorMessageSubTitle,
    required this.arrowBackOnPressedFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0,),
            child: Text(
              errorMessageTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Open Sans'
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding:  const EdgeInsets.only(right: 12.0,left: 32.0, bottom: 16.0),
            child: Text(
              errorMessageSubTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Open Sans'
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async => arrowBackOnPressedFunction(),
                // style: _theme.outlinedButtonTheme.style,
                child: const Text(
                  "Ok",
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

