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
  Map<String, dynamic> _statistics = {};
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
      final futures = await Future.wait([
        _databaseService.getTopRatedGames(limit: 5),
        _databaseService.getRealStatistics(),
      ]);

      setState(() {
        _topRatedGames = futures[0] as List<Game>;
        _statistics = futures[1] as Map<String, dynamic>;
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
        title: Row(
          children: [
            Icon(Icons.gamepad, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Steam Clone'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Yenile',
          )
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('En Yüksek Puanlı Oyunlar'),
                        const SizedBox(height: 16),
                        _buildTopRatedGames(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Platform İstatistikleri'),
                        const SizedBox(height: 16),
                        _buildStatCards(),
                        const SizedBox(height: 32),
                        _buildActionButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dijital Oyun Kütüphanesi',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'En iyi oyunları keşfedin, arkadaşlarınızla paylaşın',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
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
      children: [
        StatsCard(
          title: 'Toplam Oyun',
          value: '${_statistics['gamesCount'] ?? 0}',
          icon: Icons.games,
          color: Colors.blue,
        ),
        StatsCard(
          title: 'Toplam Kullanıcı',
          value: '${_statistics['usersCount'] ?? 0}',
          icon: Icons.people,
          color: Colors.green,
        ),
        StatsCard(
          title: 'Toplam Yorum',
          value: '${_statistics['reviewsCount'] ?? 0}',
          icon: Icons.comment,
          color: Colors.orange,
        ),
        StatsCard(
          title: 'Ortalama Puan',
          value: '${(_statistics['averageRating'] ?? 0.0).toStringAsFixed(1)}',
          icon: Icons.star,
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnalyticsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.analytics),
        label: const Text('Tüm Analitikleri Görüntüle'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
