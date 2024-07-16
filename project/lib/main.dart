import 'package:flutter/material.dart';
import 'package:project/data/database.dart';
import 'package:project/http/http_client.dart';
import 'package:project/pages/navigator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'repository/parks_repository.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
      Provider<ParkDatabase>(create: (_) => ParkDatabase())
    ],
    child: const MyApp()
    ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final database = context.read<ParkDatabase>();

    var colorScheme = ColorScheme.fromSeed(seedColor: const Color.fromRGBO(56, 105, 184, 1));

    return FutureBuilder(
      future: database.init(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('pt'),
            ],
            locale: const Locale('pt'),
            title: 'Parkease',
            theme: ThemeData(
              colorScheme: colorScheme,
              useMaterial3: true
            ),
            home: const MainPage(),
          );
        } else {
          return const MaterialApp(
            home: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
