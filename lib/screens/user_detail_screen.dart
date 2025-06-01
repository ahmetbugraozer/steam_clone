import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/library_item.dart';
import '../models/review.dart';
import '../models/wishlist_item.dart';
import '../services/database_service.dart';
import '../widgets/review_card.dart';
import 'game_detail_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late TabController _tabController;
  late Future<User> _userFuture;
  late Future<List<LibraryItem>> _libraryItemsFuture;
  late Future<List<WishlistItem>> _wishlistItemsFuture;
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _userFuture = _databaseService.getUserById(widget.userId);
    _libraryItemsFuture = _databaseService.getUserLibrary(widget.userId);
    _wishlistItemsFuture = _databaseService.getUserWishlist(widget.userId);
    _reviewsFuture = _databaseService.getUserReviews(widget.userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<User>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return const Text('Kullanıcı Detayları');
            }
            return Text(snapshot.data!.username);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'Kütüphane'),
            Tab(text: 'İstek Listesi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildProfileTab(), _buildLibraryTab(), _buildWishlistTab()],
      ),
    );
  }

  Widget _buildProfileTab() {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Kullanıcı bilgileri yüklenirken hata: ${snapshot.error}',
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Kullanıcı bulunamadı.'));
        }

        final user = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kullanıcı profil kartı
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(user.email,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(
                              'Kayıt Tarihi: ${_formatDate(user.registrationDate)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (user.lastLoginDate != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Son Giriş: ${_formatDate(user.lastLoginDate!)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Bakiye: ₺${user.balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Kullanıcı Yorumları',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildUserReviews(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserReviews() {
    return FutureBuilder<List<Review>>(
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
              child: Text('Bu kullanıcı henüz yorum yapmamış.'),
            ),
          );
        }

        return Column(
          children:
              reviews.map((review) => ReviewCard(review: review)).toList(),
        );
      },
    );
  }

  Widget _buildLibraryTab() {
    return FutureBuilder<List<LibraryItem>>(
      future: _libraryItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Kütüphane yüklenirken hata: ${snapshot.error}'),
          );
        }

        final libraryItems = snapshot.data ?? [];

        if (libraryItems.isEmpty) {
          return const Center(
            child: Text('Kullanıcının kütüphanesinde oyun bulunmuyor.'),
          );
        }

        return ListView.builder(
          itemCount: libraryItems.length,
          itemBuilder: (context, index) {
            final item = libraryItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: item.coverImageUrl.isNotEmpty
                      ? Image.network(
                          item.coverImageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[800],
                          child: const Icon(Icons.games, color: Colors.white),
                        ),
                ),
                title: Text(
                  item.gameName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.playTimeHours.toStringAsFixed(1)} saat',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (item.lastPlayedDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Son oynama: ${_formatDate(item.lastPlayedDate!)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameDetailScreen(gameId: item.gameId),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWishlistTab() {
    return FutureBuilder<List<WishlistItem>>(
      future: _wishlistItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('İstek listesi yüklenirken hata: ${snapshot.error}'),
          );
        }

        final wishlistItems = snapshot.data ?? [];

        if (wishlistItems.isEmpty) {
          return const Center(
            child: Text('Kullanıcının istek listesinde oyun bulunmuyor.'),
          );
        }

        return ListView.builder(
          itemCount: wishlistItems.length,
          itemBuilder: (context, index) {
            final item = wishlistItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: item.coverImageUrl != null &&
                          item.coverImageUrl!.isNotEmpty
                      ? Image.network(
                          item.coverImageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[800],
                          child: const Icon(Icons.games, color: Colors.white),
                        ),
                ),
                title: Text(
                  item.gameName ?? 'Bilinmeyen Oyun',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Eklenme: ${_formatDate(item.addDate)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (item.gamePrice != null)
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '₺${item.gamePrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameDetailScreen(gameId: item.gameId),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
