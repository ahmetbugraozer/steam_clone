import 'package:flutter/material.dart';
import '../models/user.dart';

class UserListTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserListTile({Key? key, required this.user, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: Icon(Icons.person,
            size: 40, color: Theme.of(context).colorScheme.primary),
        title: Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: const TextStyle(fontSize: 12)),
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
                  'Kayıt: ${_formatDate(user.registrationDate)}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.account_balance_wallet,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '₺${user.balance.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
