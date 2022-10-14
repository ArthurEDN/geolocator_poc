import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_poc/components/custom_action_chip.dart';
import 'package:geolocator_poc/components/custom_body_stopMakingRoute_widget.dart';
import 'package:geolocator_poc/utils/map_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {

  final Brightness _brightness = SchedulerBinding.instance.window.platformBrightness;
  final Completer<GoogleMapController> _mapsController = Completer();
  final ValueNotifier<bool> _theRouteWasMake = ValueNotifier(false);
  final ValueNotifier<Brightness> _notifierBrightness = ValueNotifier(Brightness.dark);
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  late final String _mapStyleStandard;
  late final String _mapStyleNight;


  @override
  void initState(){
    super.initState();
    GoogleMapUtils.initializeConfigurations();
    markers.add(
      Marker(
        markerId: const MarkerId("Bloco D"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: const LatLng(-3.770532, -38.480435),
      )
    );
    // DefaultAssetBundle.of(context).loadString('assets/maps_style/maps_night_style.json').then((string) {
    //   _mapStyleNight = string;
    // });
    // DefaultAssetBundle.of(context).loadString('assets/maps_style/maps_standard_style.json').then((string) {
    //   _mapStyleStandard = string;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ValueListenableBuilder(
              valueListenable: _notifierBrightness,
              builder: (BuildContext context, Brightness brightnessValue, Widget? child){
                if(_notifierBrightness.value == Brightness.dark){
                  _mapsController.future.then((value){
                    DefaultAssetBundle.of(context).loadString('assets/maps_style/maps_night_style.json').then((string) {
                      value.setMapStyle(string);
                    });
                  });
                  return GoogleMap(
                    onMapCreated: (GoogleMapController controller) async{
                      _mapsController.complete(controller);
                      try{
                        await GoogleMapUtils.startLocationUpdate();
                        await GoogleMapUtils.goToMyLocation(_mapsController);
                      } catch(e){
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ));
                      }
                    },
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    mapType: MapType.normal,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(-3.768964, -38.478966),
                      zoom: 18,
                    ),
                    markers: markers,
                    polylines: polylines,
                  );
                } else {
                  _mapsController.future.then((value){
                    DefaultAssetBundle.of(context).loadString('assets/maps_style/maps_standard_style.json').then((string) {
                      value.setMapStyle(string);
                    });
                  });
                  return GoogleMap(
                      onMapCreated: (GoogleMapController controller) async{
                        _mapsController.complete(controller);
                        await GoogleMapUtils.startLocationUpdate();
                        await GoogleMapUtils.goToMyLocation(_mapsController);
                      },
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                      zoomGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      mapType: MapType.normal,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(-3.768964, -38.478966),
                        zoom: 18,
                      ),
                      markers: markers,
                      polylines: polylines,
                    );
                }
              },
          ),
          Builder(
            builder: (context) {
              return CustomActionChipWidget(
                brightness: _brightness,
                title: "Bloco D",
                currentIcon: Icons.account_balance,
                mapsController: _mapsController,
                locationToGo: markers.first.position,
                displayPersistentBottomSheetFunction: () {
                  displayBottomSheetToMakeRoute(
                      context,
                  );
                },
              );
            }
          )
        ],
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _theRouteWasMake,
        builder: (BuildContext context, bool value, Widget? child){
          return FloatingActionButton(
            onPressed: value ? () async {
              await GoogleMapUtils.goToLocationAfterMakeRoute(
                _mapsController,
                LatLng(markers.first.position.latitude, markers.first.position.longitude),
                18,
              );
            } : () async{
              try{
                await GoogleMapUtils.goToMyLocation(_mapsController);
              } catch(e){
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ));
              }
            },
            child: const Icon(Icons.my_location_outlined, color: Colors.white,),
          );
        },
      ),
    );
  }

  void displayBottomSheetToMakeRoute(BuildContext context){
    Scaffold.of(context).showBottomSheet(
      elevation: 15,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
      ),
      (context){
        return SizedBox(
          height: MediaQuery.of(context).size.height/4.5,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 24.0),
                    child: IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.arrow_back_outlined),
                      color: const Color(0xFF005B9B),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0, right: 24, left: 8.0),
                      child: Text(
                        "Bloco D",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Open Sans",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0, right: 32.0,),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:() async {
                        _theRouteWasMake.value = true;
                        displayBottomSheetToStopMakingRoute(context);
                        await GoogleMapUtils.goToLocationAfterMakeRoute(
                          _mapsController,
                          markers.first.position,
                          18,
                        );
                      },
                      child: const Text(
                        "Como chegar",
                        style: TextStyle(
                          fontFamily: "Open Sans",
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
  }

  void displayBottomSheetToStopMakingRoute(BuildContext context){
    Scaffold.of(context).showBottomSheet(
      elevation: 15,
      enableDrag: false,
      (context) => CustomBodyStopMakingRouteBottomSheetWidget(
          title: "Bloco D",
          locationToGo: markers.first.position,
          arrowBackOnPressedFunction: () async {
            _theRouteWasMake.value = false;
            displayBottomSheetToMakeRoute(context);
            await GoogleMapUtils.goToLocation(
              _mapsController,
              markers.first.position,
              18,
            );
          },
          buttonOnPressedFunction: () async {
            _theRouteWasMake.value = false;
            Navigator.pop(context);
            await GoogleMapUtils.goToMyLocation(_mapsController);
            await GoogleMapUtils.hideMarkerInfoWindow(
              _mapsController,
              "Bloco D",
            );
          },
      ),
    );
  }
}
