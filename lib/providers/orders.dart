import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/consttants.dart';

import 'cart.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  Order({this.id, this.total, this.products, this.date});
}

class Orders with ChangeNotifier {

  String _token;

  String _userId;


  Orders([this._token, this._items = const [], this._userId]);

  List<Order> _items = [];

  final String _baseUrl = '${Constants.BASE_API_URL}/orders';

  List<Order> get items {
    return [..._items];
  }

  int get ordersCount {
    return _items.length;
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(Uri.parse("$_baseUrl/$_userId.json?auth=$_token"),
        body: jsonEncode({
          'total': cart.totalAmount,
          'date': date.toIso8601String(),
          'products': cart.items.values
              .map((cartItem) => {
                    'id': cartItem.id,
                    'productId': cartItem.productId,
                    'title': cartItem.title,
                    'quantity': cartItem.quantity,
                    'price': cartItem.price,
                  })
              .toList(),
        }));

    _items.insert(
      0,
      Order(
        id: jsonDecode(response.body)['name'],
        total: cart.totalAmount,
        products: cart.items.values.toList(),
        date: date,
      ),
    );
    notifyListeners();
  }

  Future<void> loadOrders() async {
    List<Order> loadeditems = [];
    final response = await http.get(Uri.parse("$_baseUrl/$_userId.json?auth=$_token"));
    Map<String, dynamic> data = jsonDecode(response.body);
    loadeditems.clear();
    if (data != null) {
      data.forEach((orderId, orderData) {
        loadeditems.add(Order(
            id: orderId,
            total: orderData['total'],
            date: DateTime.parse(orderData['date']),
            products: (orderData['products'] as List<dynamic>).map((item) {
              return CartItem(
                  id: item['id'],
                  productId: item['productId'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price']);
            }).toList()));
      });
      notifyListeners();
    }

    _items = loadeditems.reversed.toList();
    return Future.value();
  }
}
