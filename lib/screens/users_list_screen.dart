import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../widgets/user_list_tile.dart';
import 'user_detail_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<User> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Bu metodun gerçek implementasyonu database_service.dart'ta olacak
      final users = await _databaseService.getAllUsers();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Kullanıcılar yüklenirken hata: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcılar yüklenirken hata oluştu: $e')),
      );
    }
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }

    return _users.where((user) {
      return user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Kullanıcılar'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers)
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Kullanıcı ara...',
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

          // Kullanıcı listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('Kullanıcı bulunamadı.'))
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return UserListTile(
                            user: user,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserDetailScreen(userId: user.id),
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
