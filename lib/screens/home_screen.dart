import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/database_service.dart';
import '../widgets/game_card.dart';
import '../widgets/navigation_drawer.dart';
import '../widgets/stats_card.dart';
import 'game_detail_screen.dart';
import 'games_list_screen.dart';
import 'users_list_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Game> _topRatedGames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Bu metodun gerçek implementasyonu database_service.dart'ta olacak
      final games = await _databaseService.getTopRatedGames(limit: 5);

      setState(() {
        _topRatedGames = games;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Veri yüklenirken hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dijital Oyun Kütüphanesi'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)
        ],
      ),
      drawer: CustomNavigationDrawer(
        onGamesSelected: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GamesListScreen()),
          );
        },
        onUsersSelected: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UsersListScreen()),
          );
        },
        onAnalyticsSelected: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
          );
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('En Yüksek Puanlı Oyunlar'),
                    const SizedBox(height: 16),
                    _buildTopRatedGames(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Hızlı İstatistikler'),
                    const SizedBox(height: 16),
                    _buildStatCards(),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AnalyticsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Tüm Analitikleri Görüntüle'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Widget _buildTopRatedGames() {
    if (_topRatedGames.isEmpty) {
      return Center(
        child: Text(
          'Henüz oyun bulunamadı.',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _topRatedGames.length,
        itemBuilder: (context, index) {
          final game = _topRatedGames[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GameCard(
              game: game,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameDetailScreen(gameId: game.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        StatsCard(
          title: 'Toplam Oyun',
          value: '2,500+',
          icon: Icons.games,
          color: Colors.blue,
        ),
        StatsCard(
          title: 'Toplam Kullanıcı',
          value: '10,000+',
          icon: Icons.people,
          color: Colors.green,
        ),
        StatsCard(
          title: 'Toplam Yorum',
          value: '45,000+',
          icon: Icons.comment,
          color: Colors.orange,
        ),
        StatsCard(
          title: 'Ortalama Puan',
          value: '4.6',
          icon: Icons.star,
          color: Colors.amber,
        ),
      ],
    );
  }
}
