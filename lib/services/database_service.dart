import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/game.dart';
import '../models/user.dart';
import '../models/library_item.dart';
import '../models/review.dart';
import '../models/wishlist_item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // API'nin URL'si (emülatör için)

  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  // Tüm oyunları getir
  Future<List<Game>> getAllGames() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/games'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final games = data.map((item) {
          return Game.fromMap(
            item,
            genres: List<String>.from(item['genres'] ?? []),
            tags: List<String>.from(item['tags'] ?? []),
          );
        }).toList();

        // Duplicate oyunları temizle
        final Map<int, Game> uniqueGames = {};
        for (final game in games) {
          uniqueGames[game.id] = game;
        }

        final uniqueGamesList = uniqueGames.values.toList();

        // Oyunları alfabetik sıraya göre sırala
        uniqueGamesList.sort((a, b) => a.name.compareTo(b.name));

        return uniqueGamesList;
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Veri getirme hatası: $e');
      return [];
    }
  }

  // En yüksek puanlı oyunları getir
  Future<List<Game>> getTopRatedGames({int limit = 5}) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/games/top-rated?limit=$limit'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final games = data.map((item) {
          return Game.fromMap(
            item,
            genres: List<String>.from(item['genres'] ?? []),
            tags: List<String>.from(item['tags'] ?? []),
          );
        }).toList();

        // Duplicate oyunları temizle
        final Map<int, Game> uniqueGames = {};
        for (final game in games) {
          uniqueGames[game.id] = game;
        }

        return uniqueGames.values.toList();
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Veri getirme hatası: $e');
      return [];
    }
  }

  // Oyun detayını getir
  Future<Game> getGameById(int gameId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/games/$gameId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return Game.fromMap(
          data,
          genres: List<String>.from(data['genres'] ?? []),
          tags: List<String>.from(data['tags'] ?? []),
        );
      } else {
        throw Exception('Oyun bulunamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Oyun detayı getirme hatası: $e');
      rethrow;
    }
  }

  // Oyun yorumlarını getir
  Future<List<Review>> getGameReviews(int gameId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/games/$gameId/reviews'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => Review.fromMap(item)).toList();
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Yorumları getirme hatası: $e');
      return [];
    }
  }

  // Tüm kullanıcıları getir
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => User.fromMap(item)).toList();
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Kullanıcıları getirme hatası: $e');
      return [];
    }
  }

  // Kullanıcı detayını getir
  Future<User> getUserById(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return User.fromMap(data);
      } else {
        throw Exception('Kullanıcı bulunamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Kullanıcı detayı getirme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı kütüphanesini getir
  Future<List<LibraryItem>> getUserLibrary(int userId) async {
    try {
      debugPrint('Kullanıcı kütüphanesi isteniyor - UserId: $userId');
      final response =
          await http.get(Uri.parse('$baseUrl/users/$userId/library'));

      debugPrint('Kütüphane API Response Status: ${response.statusCode}');
      debugPrint('Kütüphane API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        debugPrint('Kütüphane verisi sayısı: ${data.length}');

        final libraryItems = data.map((item) {
          debugPrint('Kütüphane item verisi: $item');
          return LibraryItem.fromMap(item);
        }).toList();

        return libraryItems;
      } else {
        debugPrint(
            'Kütüphane API hatası: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint('Kütüphaneyi getirme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Kullanıcı istek listesini getir
  Future<List<WishlistItem>> getUserWishlist(int userId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/users/$userId/wishlist'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => WishlistItem.fromMap(item)).toList();
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('İstek listesini getirme hatası: $e');
      return [];
    }
  }

  // Kullanıcı yorumlarını getir
  Future<List<Review>> getUserReviews(int userId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/users/$userId/reviews'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => Review.fromMap(item)).toList();
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Yorumları getirme hatası: $e');
      return [];
    }
  }

  // En çok istek listesine eklenen oyunları getir
  Future<List<Game>> getMostWishlistedGames({int limit = 10}) async {
    try {
      debugPrint(
          'En çok istek listesine eklenen oyunlar isteniyor - limit: $limit');
      final response = await http
          .get(Uri.parse('$baseUrl/games/most-wishlisted?limit=$limit'));

      debugPrint('Most wishlisted API Response Status: ${response.statusCode}');
      debugPrint('Most wishlisted API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        debugPrint(
            'En çok istek listesine eklenen oyun sayısı: ${data.length}');

        final games = data.map((item) {
          debugPrint('Most wishlisted item verisi: $item');
          return Game.fromMap(
            item,
            genres: List<String>.from(item['genres'] ?? []),
            tags: List<String>.from(item['tags'] ?? []),
          );
        }).toList();

        // Duplicate oyunları temizle
        final Map<int, Game> uniqueGames = {};
        for (final game in games) {
          uniqueGames[game.id] = game;
        }

        final uniqueGamesList = uniqueGames.values.toList();
        debugPrint(
            'Temizlenmiş en çok istek listesine eklenen oyun sayısı: ${uniqueGamesList.length}');

        return uniqueGamesList;
      } else {
        debugPrint(
            'Most wishlisted API hatası: ${response.statusCode} - ${response.body}');

        // Fallback: En yüksek puanlı oyunları döndür
        debugPrint('Fallback olarak en yüksek puanlı oyunlar getiriliyor...');
        return await getTopRatedGames(limit: limit);
      }
    } catch (e, stackTrace) {
      debugPrint('En çok istek listesine eklenen oyunları getirme hatası: $e');
      debugPrint('Stack trace: $stackTrace');

      try {
        // Fallback: En yüksek puanlı oyunları döndür
        debugPrint(
            'Hata durumunda fallback olarak en yüksek puanlı oyunlar getiriliyor...');
        return await getTopRatedGames(limit: limit);
      } catch (fallbackError) {
        debugPrint('Fallback da başarısız: $fallbackError');
        return [];
      }
    }
  }

  // Tür istatistiklerini getir
  Future<Map<String, dynamic>> getGenreStatistics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analytics/genres'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('İstatistik getirme hatası: $e');
      return {};
    }
  }

  // Etiket istatistiklerini getir
  Future<Map<String, dynamic>> getTagStatistics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analytics/tags'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('İstatistik getirme hatası: $e');
      return {};
    }
  }

  // Genel istatistikleri getir - Gerçek API çağrıları
  Future<int> getTotalGamesCount() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/analytics/games-count'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Oyun sayısı getirme hatası: $e');
      return 0;
    }
  }

  Future<int> getTotalUsersCount() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/analytics/users-count'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Kullanıcı sayısı getirme hatası: $e');
      return 0;
    }
  }

  Future<int> getTotalReviewsCount() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/analytics/reviews-count'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Yorum sayısı getirme hatası: $e');
      return 0;
    }
  }

  Future<double> getAverageRating() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/analytics/average-rating'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['average'] ?? 0.0).toDouble();
      }
      return 0.0;
    } catch (e) {
      debugPrint('Ortalama puan getirme hatası: $e');
      return 0.0;
    }
  }

  // Gerçek istatistikleri getir - Tek API çağrısı ile
  Future<Map<String, dynamic>> getRealStatistics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analytics/overview'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'gamesCount': data['totalGames'] ?? 0,
          'usersCount': data['totalUsers'] ?? 0,
          'reviewsCount': data['totalReviews'] ?? 0,
          'averageRating': (data['avgRating'] ?? 0.0).toDouble(),
        };
      } else {
        // Fallback olarak ayrı ayrı çağırabilir
        debugPrint(
            'Overview API hatası, fallback kullanılıyor: ${response.statusCode}');
        return await _getFallbackStatistics();
      }
    } catch (e) {
      debugPrint('İstatistikler getirme hatası: $e');
      return await _getFallbackStatistics();
    }
  }

  // Fallback istatistikler
  Future<Map<String, dynamic>> _getFallbackStatistics() async {
    try {
      final futures = await Future.wait([
        getTotalGamesCount(),
        getTotalUsersCount(),
        getTotalReviewsCount(),
        getAverageRating(),
      ]);

      return {
        'gamesCount': futures[0],
        'usersCount': futures[1],
        'reviewsCount': futures[2],
        'averageRating': futures[3],
      };
    } catch (e) {
      debugPrint('Fallback istatistikler hatası: $e');
      return {
        'gamesCount': 0,
        'usersCount': 0,
        'reviewsCount': 0,
        'averageRating': 0.0,
      };
    }
  }
}
