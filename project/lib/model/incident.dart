class Incident {
  final String parkName;
  final DateTime dateTime;
  final String description;
  final String gravity;

  Incident({
    required this.parkName,
    required this.dateTime,
    required this.description,
    required this.gravity
  });

  factory Incident.fromDB(Map<String, dynamic> db) {
    return Incident(
      parkName: db['parkName'],
      dateTime: DateTime.parse(db['dateTime']),
      description: db['description'],
      gravity: db['gravity']
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'parkName': parkName,
      'dateTime': dateTime.toIso8601String(),
      'description': description,
      'gravity': gravity
    };
  }
}