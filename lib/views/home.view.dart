import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:omegainc_lib/omegainc_lib.dart';
import 'package:omegainc_lib/util/common.util.dart';
import 'package:omegainc_lib/widgets/ui/omega.appbar.widget.dart';
import 'package:omegainc_lib/widgets/ui/omega.loading.widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteadortime/consts/consts.dart';
import 'package:sorteadortime/model/player.model.dart';
import 'package:sorteadortime/model/team.model.dart';
import 'package:sorteadortime/view-model/home.viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  CommonUtil commonUtil = CommonUtil();

  HomeViewModel viewModel = HomeViewModel();

  final TextEditingController _controller = TextEditingController();
  List<PlayerModel> players = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initialize() async {
    _loadPlayers();
  }

  void _loadPlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String playersJson = prefs.getString('players') ?? '[]';
    List<dynamic> playersList = jsonDecode(playersJson);
    setState(() {
      players = playersList.map((player) => PlayerModel(player)).toList();
    });
  }

  void _savePlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playersJsonList =
        players.map((player) => player.name).toList();
    await prefs.setString('players', jsonEncode(playersJsonList));
  }

  void _sortTeams() {
    if (players.length < 10) {
      commonUtil.info(context, 'O minímo de jogadores no total é 10');
      return;
    }

    List<PlayerModel> shuffledPlayers = List.from(players)..shuffle();
    List<PlayerModel> team1Players = shuffledPlayers.sublist(0, 5);
    List<PlayerModel> team2Players = shuffledPlayers.sublist(5, 10);
    List<PlayerModel> reservePlayers = shuffledPlayers.sublist(10);

    TeamModel team1 = TeamModel('Time 1', team1Players);
    TeamModel team2 = TeamModel('Time 2', team2Players);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Times Sorteados'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${team1.name}:'),
              for (var player in team1.players)
                Text('- ${player.name}'),
              const SizedBox(height: 16),
              Text('${team2.name}:'),
              for (var player in team2.players)
                Text('- ${player.name}'),
              const SizedBox(height: 16),
              const Text('Jogadores Reservas:'),
              for (var player in reservePlayers)
                Text('- ${player.name}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _editPlayer(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String playerName = players[index].name;
        return AlertDialog(
          title: const Text('Editar Jogador'),
          content: TextField(
            controller: TextEditingController(text: playerName),
            onChanged: (value) {
              playerName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  players[index].name = playerName;
                  _savePlayers();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deletePlayer(int index) {
    setState(() {
      players.removeAt(index);
      _savePlayers();
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return LoadingOverlay(
      color: Colors.grey,
      isLoading: viewModel.isBusy,
      progressIndicator: OmegaLoadingWidget(
        textColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Consts.defaultBackground,
        appBar: OmegaAppBar(
          title: Consts.appTitle,
          bgColor: Consts.primaryColor,
          textColor: Colors.white,
          iconDataColor: Colors.white,
        ),
        body: Container(
          margin: const EdgeInsets.all(5.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Nome do jogador',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um nome.';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OmegaButton(
                      text: 'Adicionar Jogador',
                      height: 35,
                      width: screenWidth * 0.30,
                      color: Colors.red,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            players.add(PlayerModel(_controller.text));
                            _controller.clear();
                            _savePlayers();
                          });
                        }
                      },
                    ),
                    OmegaButton(
                      text: 'Sortear Times',
                      height: 35,
                      width: screenWidth * 0.30,
                      color: Colors.red,
                      onPressed: () => _sortTeams(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      var posicao = index + 1;
                      var nome = players[index].name;
                      return ListTile(
                        title: Text("${posicao} - ${nome}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editPlayer(index);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deletePlayer(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
