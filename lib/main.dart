
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator_poc/pages/mapa_page.dart';


import 'location/location_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<LocationBloc>(
        create: (context) => LocationBloc()..add(LocationStarted()),
        child: const MapaPage(),
      ),
    );
  }
}


