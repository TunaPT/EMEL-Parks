import 'package:flutter/material.dart';
import 'package:project/data/database.dart';
import 'package:project/model/favourite_park.dart';
import 'package:project/pages/list_park.dart';
import 'package:project/model/park_info.dart';
import 'package:project/repository/parks_repository.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../geolocator/location_utils.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<List<dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadDashboardData();
  }

  Future<List<dynamic>> _loadDashboardData() async {
    final parks = context.read<Parks>().getParks();
    final favouriteParks = context.read<ParkDatabase>().getFavouriteParks();
    final userPosition = determinePosition();
    
    final favouriteParksList = await favouriteParks;
    final List<Future<ParkInfo>> favouriteParksDataFutures = favouriteParksList.map((favPark) {
      return context.read<Parks>().getParkData(favPark.parkName);
    }).toList();
    
    final favouriteParksData = await Future.wait(favouriteParksDataFutures);
    
    return [await parks, favouriteParksList, await userPosition, favouriteParksData];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(47, 49, 52, 1),
        child: FutureBuilder(
          future: _dashboardData,
          builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Sem acesso à Internet', style: TextStyle(color: Colors.white)));
            } else {
              if (snapshot.hasData && snapshot.data != null) {
                List<ParkInfo> parksList = snapshot.data![0];
                List<FavouritePark> favouriteParksList = snapshot.data![1];
                Position? userPosition = snapshot.data![2]; // Snapshot com a localização do utilizador
                List<ParkInfo> favouriteParksData = snapshot.data![3];

                return SizedBox(
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: [
                                Icon(Icons.location_pin, color: Colors.white, size: 25),
                                SizedBox(width: 5),
                                Text('Perto de Mim', key: Key('near-to-me'), style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          if (userPosition == null)
                            const Padding(
                              padding: EdgeInsets.only(left: 20, top: 15, right: 20),
                              child: Align(
                                alignment: Alignment.centerLeft, // Texto alinhado à esquerda
                                child: Text('Localização não permitida', style: TextStyle(fontSize: 16, color: Colors.white),),
                              ),
                            ),
                          if (userPosition != null)
                            listNearParks(parksList, userPosition), // Passa a posição do utilizador para o cálculo dos parques próximos de si
                          const Padding(
                            padding: EdgeInsets.only(left: 20, top: 15, right: 20),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 25),
                                SizedBox(width: 5),
                                Text('Favoritos', key: Key('favourites'), style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          if (favouriteParksList.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(left: 20, top: 15, right: 20),
                              child: Align(
                                alignment: Alignment.centerLeft, // Texto alinhado à esquerda
                                child: Text('Nenhum parque adicionado', key: Key('no-favourites'), style: TextStyle(fontSize: 16, color: Colors.white),),
                              ),
                            ),
                          if (favouriteParksList.isNotEmpty)
                            listFavouriteParks(favouriteParksData, userPosition),
                        ],
                      ),
                    ),
                  ),
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

  Widget listNearParks(List<ParkInfo> parksList, Position? userPosition) { // Recebe o parâmetro de posição do utilizador

    if (userPosition != null) {
      parksList.sort((park1, park2) {
        final distance1 = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          double.parse(park1.latitude),
          double.parse(park1.longitude),
        );

        final distance2 = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          double.parse(park2.latitude),
          double.parse(park2.longitude),
        );

        return distance1.compareTo(distance2);
      });
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final parkData = parksList[index];

        String distance = calculateUserDistanceToPark(userPosition, parkData);

        return ListPark(key:Key('listPark_$index'), item: parkData, distance: distance);
      },
    );
  }

  Widget listFavouriteParks(List<ParkInfo> favouriteParksData, Position? userPosition) {
    favouriteParksData.sort((a, b) => a.name.compareTo(b.name));

    return ListView.builder(
      shrinkWrap: true,
      itemCount: favouriteParksData.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final parkData = favouriteParksData[index];

        String distance = calculateUserDistanceToPark(userPosition, parkData);

        return ListPark(item: parkData, distance: distance);
      },
    );
  }

}