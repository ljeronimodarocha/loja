import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../exceptions/http_exception.dart';
import '../utils/consttants.dart';
import 'product.dart';

class Products with ChangeNotifier {
  String _token;
  String _userId;

  Products([this._token, this._items = const [], this._userId]);

  final String _baseUrl = '${Constants.BASE_API_URL}//products';

  List<Product> _items = [];

  List<Product> get items => [..._items];

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Future<void> loadProducts() async {
    final response = await http.get(Uri.parse("$_baseUrl.json?auth=$_token"));
    final favResponse = await http.get(Uri.parse(
        "${Constants.BASE_API_URL}/userFavorites/$_userId.json?auth=$_token"));

    final Map<String, dynamic> data = jsonDecode(response.body);
    final Map<String, dynamic> favMap = jsonDecode(favResponse.body);

    _items.clear();
    if (data != null) {
      data.forEach((productID, productData) {
        final isFavorite = favMap == null ? false : favMap[productID] ?? false;
        _items.add(Product(
          id: productID,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: isFavorite,
        ));
      });
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> addProduct(Product newProduct) async {
    final response = await http.post(Uri.parse("$_baseUrl.json?auth=$_token"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
        }));

    _items.add(Product(
      id: json.decode(response.body)['name'],
      title: newProduct.title,
      description: newProduct.description,
      price: newProduct.price,
      imageUrl: newProduct.imageUrl,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product == null || product.id == null) {
      return;
    }

    final index = _items.indexWhere((prod) => prod.id == product.id);
    if (index >= 0) {
      await http.patch(Uri.parse("$_baseUrl/${product.id}.json?auth=$_token"),
          body: jsonEncode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          }));
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((prod) => prod.id == id);
    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();
      final response = await http
          .delete(Uri.parse("$_baseUrl/${product.id}.json?auth=$_token"));
      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException("Ocorreu um erro ao excluir o produto");
      }
    }
  }

  int get itemsCount {
    return _items.length;
  }
}

// bool _showFavoriteOnly = false;

/*void showFavoriteOnly() {
    _showFavoriteOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoriteOnly = false;
    notifyListeners();
  }*/
