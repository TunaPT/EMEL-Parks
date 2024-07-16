import 'package:flutter/material.dart';
import 'package:project/data/database.dart';
import 'package:project/model/favourite_park.dart';
import 'package:project/model/incident.dart';
import 'package:project/pages/app_bar.dart';
import 'package:project/pages/list_park.dart';
import 'package:project/pages/navigator.dart';
import 'package:project/repository/parks_repository.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../geolocator/location_utils.dart';
import '../model/park_info.dart';

class ParkDetails extends StatefulWidget {
  final String parkName;

  const ParkDetails({
    super.key,
    required this.parkName,
  });

  @override
  State<ParkDetails> createState() => _ParkDetailsState();
}

class _ParkDetailsState extends State<ParkDetails> {
  late Future<Position?> _userPosition;

  @override
  void initState() {
    super.initState();
    _userPosition = determinePosition(); // Variável com a localização do utilizador
  }

  @override
  Widget build(BuildContext context) {
    String parkName = widget.parkName;

    return FutureBuilder(
      future: Future.wait([
        context.read<Parks>().getParkData(parkName),
        context.read<ParkDatabase>().getIncidentsForPark(parkName),
        context.read<ParkDatabase>().getIsParkFavourite(parkName),
        _userPosition,
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Sem acesso à Internet', style: TextStyle(color: Colors.white)));
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            ParkInfo parkData = snapshot.data![0] as ParkInfo;
            List<Incident> filteredIncidents = snapshot.data![1] as List<Incident>;
            int isParkFavourite = snapshot.data![2] as int;
            Position? userPosition = snapshot.data![3] as Position?; // Snapshot com a localização do utilizador

            OccupationStatus availability = parkData.calculateAvailability(); // Dá print a OccupationStatus.livre,  OccupationStatus.parcialmenteLotado ou OccupationStatus.lotado
            String availabilityText = parkData.availabilityText(availability); // Livre, Parcialmente Lotado, Lotado

            String distanceText = calculateUserDistanceToPark(userPosition, parkData); // Cálculo da distância

            return Scaffold(
              appBar: const AppBarWidget(showBackArrow: true),
              body: CustomScrollView(
                slivers: [
                  SliverFillRemaining( // Permite a página ter scroll
                    hasScrollBody: false,
                    child: Container(
                      color: const Color.fromRGBO(47, 49, 52, 1),
                      child: Padding(
                        padding: const EdgeInsets.all(20), // Padding à volta do container principal
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info, color: Colors.white),
                                const SizedBox(width: 5),
                                const Text('Detalhes', key: Key('details'), style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                FavouriteIconWidget(widget: widget, isParkFavourite: isParkFavourite)
                              ]
                            ),
                            Text(
                              'Última Atualização: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} - ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Nome do Parque', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(parkName, style: const TextStyle(color: Color.fromRGBO(108, 160, 250, 1), fontSize: 15)),
                              ]
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Distância do Parque', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(distanceText, style: const TextStyle(color: Color.fromRGBO(108, 160, 250, 1), fontSize: 15)), // Mostra a distâncio
                              ]
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Ocupação do Parque', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text('$availabilityText (${parkData.occupation}/${parkData.capacity})', style: const TextStyle(color: Color.fromRGBO(108, 160, 250, 1), fontSize: 15)),
                              ]
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tipo de Parque', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(parkData.type, style: const TextStyle(color: Color.fromRGBO(108, 160, 250, 1), fontSize: 15)),
                              ]
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                const Icon(Icons.warning_rounded, color: Colors.white),
                                const SizedBox(width: 2),
                                Text('Incidentes (${filteredIncidents.length})', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              ]
                            ),
                            const SizedBox(height: 10),
                            incidentsView(filteredIncidents, context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Text('Not available');
          }
        }
      }
    );
  }

  Widget incidentsView(List<Incident> filteredIncidents, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: filteredIncidents.isEmpty? [ // Verifica se existem incidentes para o parque específico
                const Text('Sem incidentes a reportar', style: TextStyle(color: Color.fromRGBO(108, 160, 250, 1), fontSize: 17)),
              ] : filteredIncidents.map((incident) {
                return Column(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(66, 92, 133, 1),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color.fromRGBO(107, 129, 164, 1),
                            width: 2.0,
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Data e Hora', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                            Text('${incident.dateTime.day}/${incident.dateTime.month}/${incident.dateTime.year} - ${incident.dateTime.hour}:${incident.dateTime.minute}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            const Text('Gravidade', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                            Text('${incident.gravity}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            const Text('Descrição', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                            Text(incident.description, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ignore: must_be_immutable
class FavouriteIconWidget extends StatefulWidget {
  FavouriteIconWidget({
    super.key,
    required this.widget,
    required this.isParkFavourite,
  });

  final ParkDetails widget;
  int isParkFavourite;

  @override
  State<FavouriteIconWidget> createState() => _FavouriteIconWidgetState();
}

class _FavouriteIconWidgetState extends State<FavouriteIconWidget> {
  @override
  Widget build(BuildContext context) {
    var parkName = widget.widget.parkName; // Nome do parque

    return IconButton(
      icon: widget.isParkFavourite == 1 ? const Icon(Icons.star, color: Color.fromRGBO(56, 105, 184, 1), size: 35) : const Icon(Icons.star_border, color: Color.fromRGBO(56, 105, 184, 1), size: 35),
      onPressed: () {
        if (widget.isParkFavourite == 0) {
          widget.isParkFavourite = 1;
          context.read<ParkDatabase>().insertFavouritePark(FavouritePark(parkName: parkName));
        } else {
          widget.isParkFavourite = 0;
          context.read<ParkDatabase>().deleteFavouritePark(parkName);
        }

        showDialog( // Apresenta alerta de incidente submetido com sucesso
          context: context,
          barrierDismissible: false, // Previne fechar o alerta antes do tempo
          builder: (context) {
            Future.delayed(const Duration(seconds: 3), () { // Remove o alerta do ecrã após 3 segundos
              // Navigator.of(context).pop(true);
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const MainPage())
              );
            });
            return AlertDialog(
              title: widget.isParkFavourite == 1 ? const Text('Adicionado aos Favoritos') : const Text('Removido dos Favoritos'), // Verifica se o parque é favorito
              contentPadding: const EdgeInsets.all(20),
              backgroundColor: const Color.fromRGBO(66, 92, 133, 1),
              icon: const Icon(Icons.check),
              iconColor: Colors.white,
              titleTextStyle: const TextStyle(color: Colors.white)
            );
          }
        );
        setState(() {}); // Atualiza o widget
      }
    );
  }
}