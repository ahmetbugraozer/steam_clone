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
      final games = await _databaseService.getAllGames();

      // Duplicate oyunları temizle (aynı ID'ye sahip oyunları)
      final Map<int, Game> uniqueGames = {};
      for (final game in games) {
        uniqueGames[game.id] = game;
      }

      setState(() {
        _games = uniqueGames.values.toList();
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

    final filtered = _games.where((game) {
      return game.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          game.developerName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          game.publisherName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Filtrelenmiş sonuçlarda da tekrar eden oyunları temizle
    final Map<int, Game> uniqueFiltered = {};
    for (final game in filtered) {
      uniqueFiltered[game.id] = game;
    }

    return uniqueFiltered.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tüm Oyunlar (${_games.length})'),
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
                hintText: 'Oyun, geliştirici veya yayıncı ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
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

          // Sonuç sayısı göstergesi
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${_filteredGames.length} sonuç bulundu',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

          // Oyun listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGames.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Oyun bulunamadı.'
                                  : 'Arama kriterlerinize uygun oyun bulunamadı.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: const Text('Aramayı temizle'),
                              ),
                            ],
                          ],
                        ),
                      )
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
