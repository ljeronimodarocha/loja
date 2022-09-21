import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  void _toggleFavorite() {
    this.isFavorite = !this.isFavorite;
    notifyListeners();
  }

  Future<void> toggleFavorite(String token, String userID) async {
    _toggleFavorite();
    try {
      final String _baseUrl =
          'https://flutter-cod3r-ea2a1-default-rtdb.firebaseio.com/userFavorites/${userID}/$id.json?auth=$token';
      final response = await http.put(Uri.parse(_baseUrl),
          body: jsonEncode(isFavorite));

      if (response.statusCode >= 400) {
        _toggleFavorite();
      }
    } catch (error) {
      _toggleFavorite();
    }
  }

  @override
  String toString() {
    return 'Product{id: $id, title: $title, description: $description, price: $price, imageUrl: $imageUrl, isFavorite: $isFavorite}';
  }
}
