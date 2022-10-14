import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator_poc/utils/map_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomActionChipWidget extends StatelessWidget {
  final String title;
  final IconData currentIcon;
  final Brightness brightness;
  final Completer<GoogleMapController> mapsController;
  final LatLng locationToGo;
  final Function displayPersistentBottomSheetFunction;

  const CustomActionChipWidget({
    Key? key,
    required this.brightness,
    required this.title,
    required this.currentIcon,
    required this.displayPersistentBottomSheetFunction,
    required this.mapsController,
    required this.locationToGo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 16),
      child: ActionChip(
        shadowColor: brightness == Brightness.dark
            ? Colors.transparent
            : Colors.grey,
        label: Text(
          title,
          style: TextStyle(
              color: brightness == Brightness.dark
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF424242),
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              fontFamily: 'Open Sans'
          ),
        ),
        avatar: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            // Icons.restaurant_outlined,
            currentIcon,
            color: brightness == Brightness.dark
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF424242),
          ),
        ),
        labelPadding: const EdgeInsets.only(left: 14.0, right: 12.0),
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF212121)
            : const Color(0xFFFFFFFF),
        elevation: 3,
        onPressed: () async{
          await GoogleMapUtils.showMarkerInfoWindow(mapsController, title);
          await GoogleMapUtils.goToLocation(mapsController, locationToGo, 18);
          displayPersistentBottomSheetFunction();
        },
      ),
    );
  }
}
