import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/game.dart';
import '../models/user.dart';
import '../models/library_item.dart';
import '../models/review.dart';
import '../models/wishlist_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // API'nin URL'si (emülatör için)
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // Android emulator için
  // Gerçek cihaz için bilgisayarınızın IP adresini kullanılmalı: 'http://192.168.1.X:3000/api'
  // iOS emulator için: 'http://localhost:3000/api'

  // En yüksek puanlı oyunları getir
  Future<List<Game>> getTopRatedGames({int limit = 5}) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/games/top-rated?limit=$limit'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) {
          return Game.fromMap(
            item,
            genres: List<String>.from(item['genres'] ?? []),
            tags: List<String>.from(item['tags'] ?? []),
          );
        }).toList();
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Veri getirme hatası: $e');
      return [];
    }
  }

  // Tüm oyunları getir
  Future<List<Game>> getAllGames() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/games'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) {
          return Game.fromMap(
            item,
            genres: List<String>.from(item['genres'] ?? []),
            tags: List<String>.from(item['tags'] ?? []),
          );
        }).toList();
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
      throw e;
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
      throw e;
    }
  }

  // Kullanıcı kütüphanesini getir
  Future<List<LibraryItem>> getUserLibrary(int userId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/users/$userId/library'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => LibraryItem.fromMap(item)).toList();
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Kütüphaneyi getirme hatası: $e');
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
      final response = await http
          .get(Uri.parse('$baseUrl/games/most-wishlisted?limit=$limit'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) {
          return Game.fromMap(
            item,
            genres: List<String>.from(item['genres'] ?? []),
            tags: List<String>.from(item['tags'] ?? []),
          );
        }).toList();
      } else {
        debugPrint('API hatası: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Veri getirme hatası: $e');
      return [];
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

  // Genel istatistikleri getir
  int getTotalGamesCount() {
    return 2500; // Bu değeri API'den almak için bir request eklenebilir
  }

  int getTotalUsersCount() {
    return 10000; // Bu değeri API'den almak için bir request eklenebilir
  }

  int getTotalReviewsCount() {
    return 45000; // Bu değeri API'den almak için bir request eklenebilir
  }

  double getAverageRating() {
    return 4.6; // Bu değeri API'den almak için bir request eklenebilir
  }
}
