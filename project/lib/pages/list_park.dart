import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project/model/park_info.dart';
import 'package:project/pages/park_details.dart';

class ListPark extends StatelessWidget {
  const ListPark({
    super.key,
    required this.item,
    required this.distance
  });

  final ParkInfo item;
  final String distance;

  @override
  Widget build(BuildContext context) {

    OccupationStatus availability = item.calculateAvailability(); // Dá print a OccupationStatus.livre,  OccupationStatus.parcialmenteLotado ou OccupationStatus.lotado
    String availabilityText = item.availabilityText(availability); // Livre, Parcialmente Lotado, Lotado

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(66, 92, 133, 1),
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: const Color.fromRGBO(107, 129, 164, 1),
            width: 2,
          ),
        ),
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
              Row( // Distância da localização atual ao parque
                children: [
                  const Icon(Icons.directions, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(distance, style: const TextStyle(color: Colors.white, fontSize: 14)), // converte para 0 casas decimais
                ],
              ),
              Row(
                children: [
                  Icon(
                    availability == OccupationStatus.livre ? Icons.check_circle : 
                    availability == OccupationStatus.parcialmenteLotado ? Icons.do_not_disturb_on:
                    availability == OccupationStatus.lotado ? Icons.warning: Icons.info,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text('$availabilityText (${item.occupation}/${item.capacity})', style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white),
                  const SizedBox(width: 5),
                  Text('${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} - ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ],
          ),
          trailing: const Icon( // Coloca o ícone da seta à direita
            Icons.arrow_forward_ios_sharp,
            color: Colors.white,
            size: 20,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute( // Redireciona para a página de detalhes de parque ao clicar num item da lista
                builder: (context) => ParkDetails(parkName: item.name),
              ),
            );
          },
        ),
      ),
    );
  }
}

String calculateUserDistanceToPark(Position? userPosition, ParkInfo parkData) {
  if (userPosition == null) {
    return "Localização não permitida"; // Mensagem de erro que aparece se a posição for null
  }

  double distance = Geolocator.distanceBetween( // Cálculo da distância do utilizador aos parques
    userPosition.latitude, // Latitude da localização atual
    userPosition.longitude, // Longitude da localização atual
    double.parse(parkData.latitude), // Latitude da localização do parque
    double.parse(parkData.longitude), // Longitude da localização do parque
  );

  if (distance >= 1000) {
    double kilometers = distance / 1000;
    return "${kilometers.toStringAsFixed(1)} km";
  } else {
    return "${distance.toStringAsFixed(0)} m";
  }
}