import 'package:flutter/material.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final VoidCallback onGamesSelected;
  final VoidCallback onUsersSelected;
  final VoidCallback onAnalyticsSelected;

  const CustomNavigationDrawer({
    Key? key,
    required this.onGamesSelected,
    required this.onUsersSelected,
    required this.onAnalyticsSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 70,
                    // Eğer asset yoksa, bir placeholder kullanabiliriz
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.games, size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dijital Oyun Kütüphanesi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Admin Paneli',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.home,
              title: 'Ana Sayfa',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.games,
              title: 'Oyunlar',
              onTap: () {
                Navigator.pop(context);
                onGamesSelected();
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.people,
              title: 'Kullanıcılar',
              onTap: () {
                Navigator.pop(context);
                onUsersSelected();
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.bar_chart,
              title: 'Analitikler',
              onTap: () {
                Navigator.pop(context);
                onAnalyticsSelected();
              },
            ),
            Divider(color: Theme.of(context).dividerColor),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              title: 'Ayarlar',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.info_outline,
              title: 'Hakkında',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onBackground),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      ),
      onTap: onTap,
      hoverColor:
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
    );
  }
}
