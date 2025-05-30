import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/review.dart';
import '../services/database_service.dart';
import '../widgets/review_card.dart';

class GameDetailScreen extends StatefulWidget {
  final int gameId;

  const GameDetailScreen({Key? key, required this.gameId}) : super(key: key);

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late Future<Game> _gameFuture;
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _gameFuture = _databaseService.getGameById(widget.gameId);
    _reviewsFuture = _databaseService.getGameReviews(widget.gameId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Game>(
        future: _gameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Oyun bilgileri yüklenirken hata: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Oyun bulunamadı.'));
          }

          final game = snapshot.data!;

          return CustomScrollView(
            slivers: [
              _buildAppBar(game),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGameInfo(game),
                      const SizedBox(height: 24),
                      _buildDescription(game),
                      const SizedBox(height: 24),
                      _buildGenresAndTags(game),
                      const SizedBox(height: 24),
                      _buildSystemRequirements(game),
                      const SizedBox(height: 24),
                      _buildReviewsSection(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(Game game) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          game.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 3),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              game.coverImageUrl.isNotEmpty
                  ? game.coverImageUrl
                  : 'https://via.placeholder.com/600x300?text=No+Image',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            // Daha iyi okunabilirlik için gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfo(Game game) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Geliştirici: ${game.developerName}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Yayıncı: ${game.publisherName}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              ...[
                Text(
                  'Çıkış Tarihi: ${_formatDate(game.releaseDate!)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
              ],
              if (game.averageRating != null) ...[
                Row(
                  children: [
                    const Text('Puan: ', style: TextStyle(fontSize: 16)),
                    _buildRatingStars(game.averageRating!),
                    const SizedBox(width: 8),
                    Text(
                      '(${game.averageRating!.toStringAsFixed(1)})',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '₺${game.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    final int fullStars = rating.floor();
    final bool hasHalfStar = rating - fullStars >= 0.5;
    final int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      children: [
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star, color: Colors.amber, size: 18),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.amber, size: 18),
        for (int i = 0; i < emptyStars; i++)
          const Icon(Icons.star_border, color: Colors.amber, size: 18),
      ],
    );
  }

  Widget _buildDescription(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Oyun Açıklaması',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          game.description.isNotEmpty
              ? game.description
              : 'Açıklama bulunmuyor.',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildGenresAndTags(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Türler',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.genres.map((genre) {
            return Chip(
              label: Text(genre),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Etiketler',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.tags.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSystemRequirements(Game game) {
    if (game.systemRequirements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sistem Gereksinimleri',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(game.systemRequirements,
              style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kullanıcı Yorumları',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Review>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Yorumlar yüklenirken hata: ${snapshot.error}'),
              );
            }

            final reviews = snapshot.data ?? [];

            if (reviews.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Henüz yorum yapılmamış.'),
                ),
              );
            }

            return Column(
              children:
                  reviews.map((review) => ReviewCard(review: review)).toList(),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
