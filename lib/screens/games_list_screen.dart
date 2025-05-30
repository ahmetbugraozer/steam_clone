import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/database_service.dart';
import '../widgets/game_list_tile.dart';
import 'game_detail_screen.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  _GamesListScreenState createState() => _GamesListScreenState();
}

class _GamesListScreenState extends State<GamesListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Game> _games = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Bu metodun gerçek implementasyonu database_service.dart'ta olacak
      final games = await _databaseService.getAllGames();

      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Oyunlar yüklenirken hata: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oyunlar yüklenirken hata oluştu: $e')),
      );
    }
  }

  List<Game> get _filteredGames {
    if (_searchQuery.isEmpty) {
      return _games;
    }

    return _games.where((game) {
      return game.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          game.developerName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
          game.publisherName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Oyunlar'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGames)
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Oyun ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Oyun listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGames.isEmpty
                    ? const Center(child: Text('Oyun bulunamadı.'))
                    : ListView.builder(
                        itemCount: _filteredGames.length,
                        itemBuilder: (context, index) {
                          final game = _filteredGames[index];
                          return GameListTile(
                            game: game,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GameDetailScreen(gameId: game.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
