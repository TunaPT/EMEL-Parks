import 'package:flutter/material.dart';
import 'package:project/pages/list_park.dart';
import 'package:project/repository/parks_repository.dart';
import 'package:provider/provider.dart';
import '../model/park_info.dart';
import '../geolocator/location_utils.dart';
import 'package:geolocator/geolocator.dart';

class ParkList extends StatefulWidget {
  const ParkList({super.key});

  @override
  State<ParkList> createState() => _ParkListState();
}

class _ParkListState extends State<ParkList> {
  late Future<List<ParkInfo>> _parksFuture;
  late Future<Position?> _positionFuture;

  @override
  void initState() {
    super.initState();
    _parksFuture = context.read<Parks>().getParks();
    _positionFuture = determinePosition();
  }

  bool distanceAscendingOrder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(47, 49, 52, 1),
        child: FutureBuilder(
          future: Future.wait([
            _parksFuture,
            _positionFuture
          ]),
          builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Sem acesso à Internet', style: TextStyle(color: Colors.white)));
            } else {
              if (snapshot.hasData && snapshot.data != null) {
                List<ParkInfo> parks = snapshot.data![0];
                Position? position = snapshot.data![1];
        
                parks.sort((park1, park2) {
                  if (distanceAscendingOrder == true && position != null) {
                      
                    final distance1 = Geolocator.distanceBetween(
                      position.latitude,
                      position.longitude,
                      double.parse(park1.latitude),
                      double.parse(park1.longitude),
                    );
        
                    final distance2 = Geolocator.distanceBetween(
                      position.latitude,
                      position.longitude,
                      double.parse(park2.latitude),
                      double.parse(park2.longitude),
                    );
                    return distance1.compareTo(distance2);
                  } else {
                    return park1.name.compareTo(park2.name);
                  }
                });
        
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.list, color: Colors.white, size: 30),
                          const SizedBox(width: 5),
                          const Text('Lista de Parques', key: Key('list-parks'), style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                          const Spacer(), // O spacer é utilizado para colocar um espaço em branco entre o último widget e o próximo
                          if (position != null) orderListButton()
                        ],
                      ),
                    ),
                    Expanded(
                      child: listParks(parks, position),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return const Text('No data');
              }
            }
          }
        ),
      ),
    );
  }

  Widget listParks(List<ParkInfo> parks, Position? userPosition) {
    return ListView.builder(
      itemCount: parks.length,
      itemBuilder: (context, index) {
        final parkData = parks[index];
        String distance = calculateUserDistanceToPark(userPosition, parkData);
        return ListPark(key:Key('parkItem_$index'), item: parkData, distance: distance);
      },
    );
  }

  Widget orderListButton() { // PENDING - OBTER DISTÂNCIA DO PARQUE
    return IconButton(
      icon: Icon(
        distanceAscendingOrder ? Icons.sort_by_alpha : Icons.arrow_upward,
        color: Colors.white,
        size: 30,
      ),
      onPressed: () {
        setState(() {
          distanceAscendingOrder = !distanceAscendingOrder; // Troca a variável com o sentido da lista
        });
      },
    );
  }
}