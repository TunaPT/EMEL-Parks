import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/geolocator/location_utils.dart';
import 'package:project/model/park_info.dart';
import 'package:project/pages/park_details.dart';
import 'package:project/repository/parks_repository.dart';
import 'package:provider/provider.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  late Future<List<ParkInfo>> _parksFuture;
  late Future<LatLng?> _userLocationFuture;

  @override
  void initState() {
    super.initState();
    _parksFuture = context.read<Parks>().getParks();
    _userLocationFuture = _getUserLocation();
  }

  Future<LatLng?> _getUserLocation() async {
    Position? position = await determinePosition();
    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(47, 49, 52, 1),
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            _parksFuture, 
            _userLocationFuture
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Sem acesso à Internet', style: TextStyle(color: Colors.white)));
            } else {
              final List<dynamic> data = snapshot.data!;
              final List<ParkInfo> parks = data[0] as List<ParkInfo>;
              final LatLng? userLocation = data[1] as LatLng?;
                
              List<Marker> parkMarkers = [];
                
              for (var park in parks) {
                parkMarkers.add(
                  Marker(
                    markerId: MarkerId(park.name),
                    position: LatLng(double.parse(park.latitude), double.parse(park.longitude)),
                    onTap: () {
                      Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => ParkDetails(parkName: park.name)
                        )
                      );
                    },
                  ),
                );
              }
                
              if (userLocation != null) {
                parkMarkers.add(
                  Marker(
                    markerId: const MarkerId('user_location'),
                    position: userLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  ),
                );
              }
                
              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition:  CameraPosition(
                  target: userLocation ?? const LatLng(38.751898, -9.153703), 
                  zoom: 14.0
                ),
                markers: Set<Marker>.of(parkMarkers),
              );
            }
          } 
        ),
      ),
    );
  }
}
