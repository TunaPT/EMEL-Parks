import 'package:flutter/material.dart';
import 'package:project/data/database.dart';
import 'package:project/model/incident.dart';
import 'package:project/model/park_info.dart';
import 'package:project/pages/navigator.dart';
import 'package:project/repository/parks_repository.dart';
import 'package:provider/provider.dart';

class IncidentLog extends StatefulWidget {
  const IncidentLog({super.key});

  @override
  State<IncidentLog> createState() => _IncidentLogState();
}

class _IncidentLogState extends State<IncidentLog> {
  String _selectedPark = ''; // Init | Guarda o valor do parque selecionado no menu dropwdown
  DateTime _dateTime = DateTime.now(); // Init | Guarda o valor selecionado no calendário
  String _description = ''; // Init| Guarda a descrição de incidente
  String _selectedGravity = ''; // Init | Guarda a gravidade do incidente

  late Future<List<ParkInfo>> _parksFuture;

  @override
  void initState() {
    super.initState();
    _parksFuture = context.read<Parks>().getParks();
  }

  Future<DateTime?> pickDate(BuildContext context) { // Criação do calendário 
    return showDatePicker(context: context, initialDate: _dateTime, firstDate: DateTime(2024), lastDate: DateTime.now());
  }

  Future<TimeOfDay?> pickTime(BuildContext context) { // Criação da seleção de hora
    return showTimePicker(context: context, initialTime: TimeOfDay(hour: _dateTime.hour, minute: _dateTime.minute), initialEntryMode: TimePickerEntryMode.input,builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final hours = _dateTime.hour.toString().padLeft(2, '0'); // Obtém as horas do DateTime
    final minutes = _dateTime.minute.toString().padLeft(2, '0'); // Obtém os minutos do DateTime

    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(47, 49, 52, 1), // Cor do Fundo
        child: FutureBuilder(
          future: _parksFuture, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Sem acesso à Internet', style: TextStyle(color: Colors.white)));
            } else {
              final parks = snapshot.data!;
              return SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Container(
                    color: const Color.fromRGBO(47, 49, 52, 1), // Cor do Fundo
                    child: Padding(
                      padding: const EdgeInsets.all(20), // Padding à volta do container principal
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning,color: Colors.white, size: 25),
                              SizedBox(width: 5),
                              Text('Reportar Incidente', key: Key('report-incident'), style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 15), 
                          Row(
                            children: [
                              const Text('Nome do Parque', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                              const Text(' '),
                              if (_selectedPark == '') const Text('*', style: TextStyle(fontSize: 16, color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: buildParkNameDropdownMenu(parks),
                          ),
                          const SizedBox(height: 15),
                          const Text('Data e Hora', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Centra os elementos na linha
                            children: [
                              Expanded(child: buildCalendarButton(context)),
                              const SizedBox(width: 30), // Espaço entre os dois botões
                              Expanded(child: buildTimeButton(hours, minutes, context)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Text('Descrição do Incidente', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                              const Text(' '),
                              if (_description == '') const Text('*', style: TextStyle(fontSize: 16, color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: buildDescriptionTextField(),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Text('Gravidade do Incidente', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                              const Text(' '),
                              if (_selectedGravity == '') const Text('*', style: TextStyle(fontSize: 16, color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: buildGravityDropdownMenu(),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: buildSubmitButton(context),
                          )
                        ],
                      ),
                    ),
                  )
                ),
              );
            }
          }
        )
      )
    );
  }

 Widget buildParkNameDropdownMenu(List<ParkInfo> parks) {
    parks.sort((a, b) => a.name.compareTo(b.name));

    return DropdownMenu(
      width: MediaQuery.of(context).size.width - 40, // Comprimento do widget
      label: const Text('Selecione o Parque'),
      textStyle: const TextStyle(color: Colors.white), // Cor do elemento quando selecionado
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: Color.fromRGBO(66, 92, 133, 1), // Cor do fundo do dropdown menu
        filled: true, // Preenche toda a cor do fundo
        labelStyle: TextStyle(color: Colors.white), // Cor do texto da label
      ),
      dropdownMenuEntries: <DropdownMenuEntry<String>>[
        for (var park in parks) 
          DropdownMenuEntry(value: park.name, label: park.name),
      ],
      onSelected: (selectedPark) { // Ação quando selecionado um elemento
        if (selectedPark != null) {
          setState(() {
            _selectedPark = selectedPark; // Guarda o valor selecionado
          });
        }
      },
    );
  }

  Widget buildCalendarButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.calendar_month_outlined),
      label: Text('${_dateTime.day}/${_dateTime.month}/${_dateTime.year}'),
      style: ButtonStyle(
        fixedSize: const MaterialStatePropertyAll(Size(180, 50)), // Tamanho do botão
        foregroundColor: const MaterialStatePropertyAll(Colors.white), // Cor do texto e do ícone
        backgroundColor: const MaterialStatePropertyAll(Color.fromRGBO(66, 92, 133, 1)), // Cor do fundo
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), // Borda do botão
      ),
      onPressed: () async {
        final date = await pickDate(context);
        if (date != null) { // Verifica se o utilizador não clicou em cancel ou fechou a janela
          final newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            _dateTime.hour,
            _dateTime.minute
          );
          setState(() { // Atualiza com os novos dados
            _dateTime = newDateTime;
          });
        }
      },
    );
  }

  Widget buildTimeButton(String hours, String minutes, BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.access_time_rounded),
      label: Text('$hours:$minutes'),
      style: ButtonStyle(
        fixedSize: const MaterialStatePropertyAll(Size(140, 50)), // Tamanho do botão
        foregroundColor: const MaterialStatePropertyAll(Colors.white), // Cor do texto e do icone
        backgroundColor: const MaterialStatePropertyAll(Color.fromRGBO(66, 92, 133, 1)), // Cor do fundo
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), // Borda do botão
      ),
      onPressed: () async {
        final time = await pickTime(context);
        if (time != null) { // Verifica se o utilizador não clicou em cancel ou fechou a janela
          final newDateTime = DateTime(
            _dateTime.year,
            _dateTime.month,
            _dateTime.day,
            time.hour,
            time.minute,
          );
          setState(() { // Atualiza com os novos dados
             _dateTime = newDateTime;
          });
        }
      },
    );
  }

  Widget buildDescriptionTextField() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        fillColor: const Color.fromRGBO(66, 92, 133, 1),
        filled: true,
        border: const OutlineInputBorder(),
        hintText: 'Insira uma descrição do incidente...',
        hintStyle: const TextStyle(color: Colors.white),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 40,
          maxHeight: double.infinity, // Permite o texto expandir na vertical
        ),
      ),
      onChanged: (text) { // Quando se adiciona novos caracteres atualiza aqui
        setState(() {
          _description = text;
        });
      },
      maxLines: null, // Permite um numero ilimitado de linhas
    );
  }

  Widget buildGravityDropdownMenu() {
    return DropdownMenu(
      width: MediaQuery.of(context).size.width - 40, // Comprimento do widget
      label: const Text('Selecione a Gravidade'),
      textStyle: const TextStyle(color: Colors.white), // Cor do elemento quando selecionado
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: Color.fromRGBO(66, 92, 133, 1), // Cor do fundo do dropdown menu
        filled: true, // Preenche a cor do fundo todo
        labelStyle: TextStyle(color: Colors.white) // Cor do texto da label
      ),
      dropdownMenuEntries: const <DropdownMenuEntry<String>>[ // A entrada é do tipo String | Elementos do dropdown menu
        DropdownMenuEntry(value: '1 - Muito Leve', label: '1 - Muito Leve'),
        DropdownMenuEntry(value: '2 - Leve', label: '2 - Leve'),
        DropdownMenuEntry(value: '3 - Moderado', label: '3 - Moderado'),
        DropdownMenuEntry(value: '4 - Grave', label: '4 - Grave'),
        DropdownMenuEntry(value: '5 - Muito Grave', label: '5 - Muito Grave'),
      ],
      onSelected: (selectedGravity) { // Ação quando selecionado um elemento
        if (selectedGravity != null) {
          setState(() {
            _selectedGravity = selectedGravity; // Guarda o valor selecionado
          });
        }
      },
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    final incidentsDatabase = context.read<ParkDatabase>();
    return ElevatedButton(
      key: const Key('submit-incident'),
      style: ButtonStyle(
        fixedSize: const MaterialStatePropertyAll(Size(150, 50)), // Tamanho do botão
        foregroundColor: const MaterialStatePropertyAll(Colors.white), // Cor do texto e do icone
        backgroundColor: _selectedPark.isNotEmpty && _description.isNotEmpty && _selectedGravity.isNotEmpty? const MaterialStatePropertyAll(Color.fromRGBO(66, 92, 133, 1)) : const MaterialStatePropertyAll(Color.fromRGBO(137, 137, 137, 1)), // Verifica se os itens necessários foram prenchidos
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), // Borda do botão
      ),
      onPressed: () { 

        if (_selectedPark.isNotEmpty && _description.isNotEmpty && _selectedGravity.isNotEmpty) { // Verifica se os itens necessários foram prenchidos
          // Neste bloco tenho todos os meus dados validados
          Incident incident = Incident(parkName: _selectedPark, dateTime: _dateTime, description: _description, gravity: _selectedGravity); // Cria um novo objeto incidente

          incidentsDatabase.insertIncident(incident);
                    
          showDialog( // Mostra alerta de submissão com sucesso
            context: context,
            barrierDismissible: false, // Previne fechar o alerta antes do tempo 
            builder: (context) => const AlertDialog(
              title: Text('Submetido com Sucesso'),
              contentPadding: EdgeInsets.all(20),
              backgroundColor: Color.fromRGBO(66, 92, 133, 1),
              icon: Icon(Icons.check),
              iconColor: Colors.white,
              titleTextStyle: TextStyle(color: Colors.white)
            )
          );
          Future.delayed(const Duration(seconds: 3), () { // Espera 3 segundos e redireciona para a página da dashboard
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const MainPage())
            );
          });
        } else {
          showDialog( // Mostra alerta de submissão com sucesso
            context: context,
            barrierDismissible: false, // Previne fechar o alerta antes do tempo 
            builder: (context) => const AlertDialog(
              title: Text('Não preencheu todos os campos obrigatórios', key: Key('not-submitted-warning'),),
              contentPadding: EdgeInsets.all(20),
              backgroundColor: Color.fromRGBO(66, 92, 133, 1),
              icon: Icon(Icons.error),
              iconColor: Colors.white,
              titleTextStyle: TextStyle(color: Colors.white)
            )
          );
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pop(); 
          });
        }
                    
        
      }, // Não cumprindo os requisitos, o botão não é clicável
      child: const Text('Submeter'),
    );
  }

}
