import 'package:flutter/material.dart';
import '../models/game.dart';

class GameListTile extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameListTile({Key? key, required this.game, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: game.coverImageUrl.isNotEmpty
              ? Image.network(
                  game.coverImageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.white),
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[800],
                  child: const Icon(Icons.games, color: Colors.white),
                ),
        ),
        title: Text(game.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${game.developerName} | ${game.publisherName}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (game.averageRating != null) ...[
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    game.averageRating!.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(
                  Icons.attach_money,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '₺${game.price.toStringAsFixed(2)}',
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
}
