import 'dart:convert';
import 'package:project/http/http_client.dart';
import 'package:project/model/park_info.dart';

class Parks {

  final HttpClient _client;

  Parks({required HttpClient client}) : _client = client;

  Future<Null> getParkInfo() async {
    return null;
  }

  Future<List<ParkInfo>> getParks() async { // Devolve os dados ordenados por distância
    
    final response = await _client.get(
      url: 'https://emel.city-platform.com/opendata/parking/lots',
      headers: {'api_key': '93600bb4e7fee17750ae478c22182dda'},
      );

    if(response.statusCode == 200){
      final responseJSON = jsonDecode(response.body);
      List parksJSON = responseJSON;
      
      List<ParkInfo> parks = parksJSON.map((parkJSON) => ParkInfo.fromMap(parkJSON)).toList();
      
      return parks;
    } else {
      throw Exception('Status Code: ${response.statusCode}');
    }
  }

  Future<ParkInfo> getParkData(String parkName) async {

    final List<ParkInfo> list = await getParks(); 

    for (var item in list) {
      if (item.name == parkName) {
        return item;
      }
    }
    throw Exception('Erro ao procurar pelo parque: $parkName');
  }
}