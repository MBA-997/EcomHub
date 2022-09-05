import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

const API = 'ecomhub-a440c-default-rtdb.firebaseio.com';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus() async {
    final oldStatus = isFavorite;

    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.https(API, '/products/$id');

    return http
        .patch(
      url,
      body: json.encode({'isFavorite': isFavorite}),
    )
        .then((response) {
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
        throw const HttpException('Could not set Favorite.');
      }
      isFavorite = !isFavorite;

      notifyListeners();
    }).catchError((error) {
      isFavorite = oldStatus;
      notifyListeners();

      throw error;
    });
  }
}
