import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/data/database.dart';
import 'package:project/http/http_client.dart';
import 'package:project/main.dart';
import 'package:project/repository/parks_repository.dart';
import 'package:provider/provider.dart';

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // Assegura que todos os widgets estão bem inicializados

  testWidgets('Test open app', (widgetTester) async {
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );
  });

  testWidgets('Test navigation to list page', (widgetTester) async {
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    Finder navigation;

    navigation = find.byKey(const Key('navigation_list'));
    expect(navigation, findsOneWidget);

    await widgetTester.tap(navigation);
  });

  testWidgets('Test navigation to map page', (widgetTester) async {
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    Finder navigation;

    navigation = find.byKey(const Key('navigation_map'));
    expect(navigation, findsOneWidget);

    await widgetTester.tap(navigation);
  });

  testWidgets('Test navigation to incident page', (widgetTester) async {
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    Finder navigation;

    navigation = find.byKey(const Key('navigation_incident'));
    expect(navigation, findsOneWidget);

    await widgetTester.tap(navigation);
  });

  testWidgets('Test without favourites', (widgetTester) async { 
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    final noFavouritesTextFinder = find.byKey(const Key('no-favourites'));
    expect(noFavouritesTextFinder, findsOneWidget);

    Text noFavouritesTextWidget = widgetTester.widget(noFavouritesTextFinder);
    expect(noFavouritesTextWidget.data, 'Nenhum parque adicionado');
  });

  testWidgets('Test near to me label', (widgetTester) async { 
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    final nearToMeTextFinder = find.byKey(const Key('near-to-me'));
    expect(nearToMeTextFinder, findsOneWidget);

    Text nearToMeTextWidget = widgetTester.widget(nearToMeTextFinder);
    expect(nearToMeTextWidget.data, 'Perto de Mim');
  });

  testWidgets('Test favourites label', (widgetTester) async { 
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    final favouritesTextFinder = find.byKey(const Key('favourites'));
    expect(favouritesTextFinder, findsOneWidget);

    Text favouritesTextWidget = widgetTester.widget(favouritesTextFinder);
    expect(favouritesTextWidget.data, 'Favoritos');
  });

  testWidgets('Test listNearParks widget', (widgetTester) async {
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    final parkItem0Finder = find.byKey(const Key('listPark_0'));
    expect(parkItem0Finder, findsOneWidget);

    final parkItem1Finder = find.byKey(const Key('listPark_1')); 
    expect(parkItem1Finder, findsOneWidget);
  });

  testWidgets('Test list parks label', (widgetTester) async { 
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    Finder navigation;

    navigation = find.byKey(const Key('navigation_list'));
    expect(navigation, findsOneWidget);

    await widgetTester.tap(navigation);

    await widgetTester.pumpAndSettle();

    final listParksTextFinder = find.byKey(const Key('list-parks'));
    expect(listParksTextFinder, findsOneWidget);

    Text listParksTextWidget = widgetTester.widget(listParksTextFinder);
    expect(listParksTextWidget.data, 'Lista de Parques');
  });

  testWidgets('Test access second park details page', (widgetTester) async { 
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    Finder navigation;

    navigation = find.byKey(const Key('navigation_list'));
    expect(navigation, findsOneWidget);

    await widgetTester.tap(navigation);

    await widgetTester.pumpAndSettle();

    final parkFinder = find.byKey(const Key('parkItem_1'));
    expect(parkFinder, findsOneWidget);

    await widgetTester.tap(parkFinder);

    await widgetTester.pumpAndSettle();

    final detailsTextFinder = find.byKey(const Key('details'));
    expect(detailsTextFinder, findsOneWidget);

    Text detailsTextWidget = widgetTester.widget(detailsTextFinder);
    expect(detailsTextWidget.data, 'Detalhes');
  });

  testWidgets('Test incident label', (widgetTester) async { 
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    Finder navigation;

    navigation = find.byKey(const Key('navigation_incident'));
    expect(navigation, findsOneWidget);

    await widgetTester.tap(navigation);

    await widgetTester.pumpAndSettle();

    final incidentTextFinder = find.byKey(const Key('report-incident'));
    expect(incidentTextFinder, findsOneWidget);

    Text incidentTextWidget = widgetTester.widget(incidentTextFinder);
    expect(incidentTextWidget.data, 'Reportar Incidente');
  });

  testWidgets('Test submit incident', (widgetTester) async { 
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Parks>(create: (_) => Parks(client: HttpClient())), 
          Provider<ParkDatabase>(create: (_) => ParkDatabase()),
        ],
        child: const MyApp(),
      ),
    );

    await widgetTester.pumpAndSettle(); // Atualiza o estado da interface

    Finder navigation;

    navigation = find.byKey(const Key('navigation_incident'));
    expect(navigation, findsOneWidget);

    await widgetTester.tap(navigation);

    await widgetTester.pumpAndSettle();

    final submitIncidentFinder = find.byKey(const Key('submit-incident'));
    expect(submitIncidentFinder, findsOneWidget);

    await widgetTester.tap(submitIncidentFinder);

    await widgetTester.pumpAndSettle();

    final notSubmittedWarningFinder = find.byKey(const Key('not-submitted-warning'));
    expect(notSubmittedWarningFinder, findsOneWidget);

    Text detailsTextWidget = widgetTester.widget(notSubmittedWarningFinder);
    expect(detailsTextWidget.data, 'Não preencheu todos os campos obrigatórios');
  });

}