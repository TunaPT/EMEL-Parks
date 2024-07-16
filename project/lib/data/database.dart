import 'package:project/model/favourite_park.dart';
import 'package:project/model/incident.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ParkDatabase {
  Database? _database;

  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      version: 1,
    );

    await createIncidentsTable();
    await createFavouriteParksTable();
  }

  Future<void> createIncidentsTable() async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database?');
    }

    await _database!.execute(
      'CREATE TABLE IF NOT EXISTS incidents ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'parkName TEXT NOT NULL,'
        'dateTime TEXT NOT NULL,'
        'description TEXT NOT NULL,'
        'gravity INTEGER NOT NULL'
      ')',
    );
  }

  Future<void> createFavouriteParksTable() async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database?');
    }

    await _database!.execute(
      'CREATE TABLE IF NOT EXISTS favouriteParks ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'parkName TEXT NOT NULL'
      ')',
    );
  }

  Future<List<Incident>> getIncidentsForPark(String parkName) async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database?');
    }

    List result = await _database!.rawQuery("SELECT * FROM incidents WHERE parkName = ?", [parkName]);

    return result
      .map((entry) => Incident.fromDB(entry))
      .toList();
  }

  Future<void> insertIncident(Incident incident) async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database?');
    }

    await _database!.insert('incidents', incident.toDb());
  }

  Future<int> getIsParkFavourite(String parkName) async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database?');
    }

    List result = await _database!.rawQuery("SELECT * FROM favouriteParks WHERE parkName = ?", [parkName]);

    return result.length;
  }

  Future<List<FavouritePark>> getFavouriteParks() async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database?');
    }

    List result = await _database!.rawQuery("SELECT * FROM favouriteParks");

    return result
      .map((entry) => FavouritePark.fromDB(entry))
      .toList();
  }

  Future<void> insertFavouritePark(FavouritePark favouritePark) async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database?');
    }

    await _database!.insert('favouriteParks', favouritePark.toDb());
  }

  Future<void> deleteFavouritePark(String parkName) async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database?');
    }

    await _database!.delete('favouriteParks', where: 'parkName = ?', whereArgs: [parkName]);
  }

}