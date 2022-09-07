import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'product.dart';
import '../models/http_exception.dart';

const API = 'ecomhub-a440c-default-rtdb.firebaseio.com';

class ProductsProvider with ChangeNotifier {
  List<Product> itemsData = [];

  final String authToken;
  final String userId;

  ProductsProvider(
      {required this.authToken, required this.userId, required this.itemsData});

  List<Product> get items {
    return [...itemsData];
  }

  List<Product> get favoriteItems {
    return itemsData.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return itemsData.firstWhere((item) => item.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&eualTo="$userId"' : '';
    var url = Uri.https(API, '/products.json?auth=$authToken$filterString');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      if (extractedData == null) return;

      url = Uri.https(API, '/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });

      itemsData = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(API, '/products.json?auth=$authToken');

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
          }));

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      itemsData.add(newProduct);

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    final index = itemsData.indexWhere((prod) => prod.id == productId);

    if (index >= 0) {
      final url = Uri.https(API, '/products/$productId.json?auth=$authToken');

      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      itemsData[index] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url = Uri.https(API, '/products/$productId.json?auth=$authToken');
    final existingProductIndex =
        itemsData.indexWhere((prod) => prod.id == productId);
    Product? existingProduct = itemsData[existingProductIndex];

    itemsData.removeWhere((prod) => prod.id == productId);
    notifyListeners();

    return http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product.');
      }
      existingProduct = null;
    }).catchError((error) {
      itemsData.insert(existingProductIndex, existingProduct as Product);
      notifyListeners();
      throw error;
    });
  }
}
