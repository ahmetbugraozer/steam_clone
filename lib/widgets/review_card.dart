import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Kullanıcı profil resmi
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                // Kullanıcı adı ve puan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildRatingStars(review.rating.toDouble()),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review.reviewDate),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.reviewText!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.thumb_up, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text('${review.helpfulCount}',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.thumb_down, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text('${review.notHelpfulCount}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    final int fullStars = rating.floor();
    final bool hasHalfStar = rating - fullStars >= 0.5;
    final int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star, color: Colors.amber, size: 16),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.amber, size: 16),
        for (int i = 0; i < emptyStars; i++)
          const Icon(Icons.star_border, color: Colors.amber, size: 16),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
