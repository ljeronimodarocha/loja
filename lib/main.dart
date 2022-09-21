import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/utils/app_routes.dart';
import 'package:shop/views/auth_home.dart';
import 'package:shop/views/cart_screen.dart';
import 'package:shop/views/oders_screen.dart';
import 'package:shop/views/product_detail_screen.dart';
import 'package:shop/views/products_overview_screen.dart';
import 'package:shop/views/products_screen.dart';

import './providers/products.dart';
import './views/product_form_screen.dart';

//parei no modulo 11 aula 15(iniciar aula 11)
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => new Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => new Products(),
          update: (ctx, auth, previousProducts) =>
              new Products(auth.token, previousProducts.items, auth.userId),
        ),
        ChangeNotifierProvider(
          create: (ctx) => new Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => new Orders(),
          update: (ctx, auth, previousOrders) =>
              new Orders(auth.token, previousOrders.items, auth.userId),
        ),
      ],
      child: MaterialApp(
        title: 'Minha Loja',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.purple,
            ).copyWith(
              secondary: Colors.deepOrange,
            ),
            fontFamily: 'Lato'),
        home: AuthOrHome(),
        debugShowCheckedModeBanner: false,
        routes: {
          AppRoutes.HOME: (ctx) => ProductOverViewScreen(),
          AppRoutes.PRODUCT_DETAIL: (ctx) => ProductDetailScreen(),
          AppRoutes.CART: (ctx) => CartScreen(),
          AppRoutes.ORDERS: (ctx) => OrderScreen(),
          AppRoutes.PRODUCTS: (ctx) => ProductsScreen(),
          AppRoutes.PRODUCT_FORM: (ctx) => ProductFormScreen(),
        },
      ),
    );
  }
}
