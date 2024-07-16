class FavouritePark {
  final String parkName;

  FavouritePark({
    required this.parkName
  });

  factory FavouritePark.fromDB(Map<String, dynamic> db) {
    return FavouritePark(
      parkName: db['parkName']
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'parkName': parkName,
    };
  }
}
