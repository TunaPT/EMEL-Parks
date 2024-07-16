import 'package:geolocator/geolocator.dart';

Future<Position?> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    return null; // Return null se os serviços de localização estiverem desativados
  }

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return null; // Return null se a permissão for negada
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return null; // Return null se a permissão for negada para sempre
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}