enum OccupationStatus { lotado, parcialmenteLotado, livre }

class ParkInfo {
  final String name;
  final String type;
  final String latitude;
  final String longitude;
  final int occupation;
  final String occupationData;
  final int capacity;

  ParkInfo({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.occupation,
    required this.occupationData,
    required this.capacity,
  });

  factory ParkInfo.fromMap(Map<String, dynamic> map){
    return ParkInfo(
      name: map['nome'],
      type: map['tipo'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      occupation: map['ocupacao'],
      occupationData: map['data_ocupacao'],
      capacity: map['capacidade_max']);
  }

  OccupationStatus calculateAvailability() { // Calcula a disponibilidade do parque de estacionado
    double percentageOccupied = occupation / capacity * 100;
    if (occupation == capacity) {
      return OccupationStatus.lotado;
    } else if (percentageOccupied >= 80) { // Verifica se a ocupação é maior ou igual a 80% da capacidade do parque
      return OccupationStatus.parcialmenteLotado;
    } else {
      return OccupationStatus.livre;
    }
  }

  String availabilityText(OccupationStatus occupationState) {
    switch (occupationState) {
      case OccupationStatus.lotado:
        return 'Lotado';
      case OccupationStatus.parcialmenteLotado:
        return 'Parcialmente Lotado';
      case OccupationStatus.livre:
        return 'Livre';
    }
  }

}