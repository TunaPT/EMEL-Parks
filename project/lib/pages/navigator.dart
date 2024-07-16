import 'package:flutter/material.dart';
import 'package:project/pages/app_bar.dart';
import 'package:project/pages/dashboard.dart';
import 'package:project/pages/incident_log.dart';
import 'package:project/pages/navigation.dart';
import 'package:project/pages/park_list.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(showBackArrow: false),

      body: [const Dashboard(), const ParkList(), const Navigation(), const IncidentLog()][_selectedIndex],

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData( 
          labelTextStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)) // Permite alterar a cor da navigation bar
        ),

        child: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home, color: Colors.white), 
              label: 'Home',
              key: Key('navigation_home'),
            ),
            NavigationDestination(
              icon: Icon(Icons.list, color: Colors.white), 
              label: 'Lista',
              key: Key('navigation_list'),
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: Colors.white), 
              label: 'Mapa',
              key: Key('navigation_map'),
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books, color: Colors.white), 
              label: 'Incidente',
              key: Key('navigation_incident'),
            )
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() { // Atualiza a página com o novo index e com isso o body é também atualizado depois do refresh
              _selectedIndex = index;
            });
          },
          indicatorColor: const Color.fromRGBO(66, 92, 133, 1), // Altera a cor do fundo do icone da página atual
          backgroundColor: const Color.fromRGBO(56, 105, 184, 1), // Altera a cor da barra de navegação
        ),
      ),

    );
  }
}
