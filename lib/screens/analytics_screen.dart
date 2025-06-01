import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/database_service.dart';
import '../widgets/game_list_tile.dart';
import '../widgets/stats_card.dart';
import 'game_detail_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late TabController _tabController;
  bool _isLoading = true;

  // Analitik veriler
  List<Game> _topRatedGames = [];
  List<Game> _mostWishlistedGames = [];
  Map<String, dynamic> _genreStats = {};
  Map<String, dynamic> _tagStats = {};
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Analitik verileri yükleniyor...');

      // Tüm verileri paralel olarak yükle
      final futures = await Future.wait([
        _databaseService.getTopRatedGames(limit: 10),
        _databaseService.getMostWishlistedGames(limit: 10),
        _databaseService.getGenreStatistics(),
        _databaseService.getTagStatistics(),
        _databaseService.getRealStatistics(),
      ]);

      debugPrint('Top rated games: ${(futures[0] as List<Game>).length}');
      debugPrint('Most wishlisted games: ${(futures[1] as List<Game>).length}');
      debugPrint('Genre stats: ${(futures[2] as Map<String, dynamic>).length}');
      debugPrint('Tag stats: ${(futures[3] as Map<String, dynamic>).length}');

      setState(() {
        _topRatedGames = futures[0] as List<Game>;
        _mostWishlistedGames = futures[1] as List<Game>;
        _genreStats = futures[2] as Map<String, dynamic>;
        _tagStats = futures[3] as Map<String, dynamic>;
        _statistics = futures[4] as Map<String, dynamic>;
        _isLoading = false;
      });

      debugPrint('Analitik verileri başarıyla yüklendi');
    } catch (e, stackTrace) {
      debugPrint('Analitik veriler yüklenirken hata: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitikler'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Genel Bakış'),
            Tab(text: 'En Yüksek Puanlı'),
            Tab(text: 'En Çok İstek Listesine Eklenen'),
            Tab(text: 'Tür/Etiket Analizi'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTopRatedTab(),
                _buildMostWishlistedTab(),
                _buildGenreTagAnalysisTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform İstatistikleri',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
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
                value:
                    '${(_statistics['averageRating'] ?? 0.0).toStringAsFixed(1)}',
                icon: Icons.star,
                color: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'En Yüksek Puanlı Oyunlar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_topRatedGames.isEmpty)
            const Center(child: Text('Veri bulunamadı.'))
          else
            for (int i = 0; i < 5 && i < _topRatedGames.length; i++)
              GameListTile(
                game: _topRatedGames[i],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GameDetailScreen(gameId: _topRatedGames[i].id),
                    ),
                  );
                },
              ),
          const SizedBox(height: 32),
          const Text(
            'En Çok İstek Listesine Eklenen',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_mostWishlistedGames.isEmpty)
            const Center(child: Text('Veri bulunamadı.'))
          else
            for (int i = 0; i < 5 && i < _mostWishlistedGames.length; i++)
              GameListTile(
                game: _mostWishlistedGames[i],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameDetailScreen(
                        gameId: _mostWishlistedGames[i].id,
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildTopRatedTab() {
    return ListView.builder(
      itemCount: _topRatedGames.length,
      itemBuilder: (context, index) {
        final game = _topRatedGames[index];
        return GameListTile(
          game: game,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameDetailScreen(gameId: game.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMostWishlistedTab() {
    if (_mostWishlistedGames.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'En çok istek listesine eklenen oyun bulunamadı.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Veritabanında istek listesine eklenmiş oyun bulunmuyor olabilir.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _mostWishlistedGames.length,
        itemBuilder: (context, index) {
          final game = _mostWishlistedGames[index];
          return GameListTile(
            game: game,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailScreen(gameId: game.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGenreTagAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Türlere Göre Oyun Dağılımı',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_genreStats.isEmpty)
            const Center(child: Text('Veri bulunamadı.'))
          else
            ..._genreStats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          flex: entry.value['count'] as int,
                          child: Container(
                            height: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value['count']} oyun (Ort. ${entry.value['avgRating'].toStringAsFixed(2)} puan)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 32),
          const Text(
            'Etiketlere Göre Popülerlik',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_tagStats.isEmpty)
            const Center(child: Text('Veri bulunamadı.'))
          else
            ..._tagStats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          flex: entry.value['count'] as int,
                          child: Container(
                            height: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value['count']} oyun (${entry.value['userCount']} kullanıcı)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 32),
          const Text(
            'Çok Oyunculu Oyunlar Analizi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Çok Oyunculu Etiketli Oyunlar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toplam ${_tagStats.containsKey("Çok Oyunculu") ? _tagStats["Çok Oyunculu"]["count"] : 0} oyun',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ortalama puan: ${_tagStats.containsKey("Çok Oyunculu") ? _tagStats["Çok Oyunculu"]["avgRating"].toStringAsFixed(2) : "N/A"}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sahiplenen kullanıcı sayısı: ${_tagStats.containsKey("Çok Oyunculu") ? _tagStats["Çok Oyunculu"]["userCount"] : 0}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
