import 'package:flutter/material.dart';
import 'package:shop/providers/product.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen();

  @override
  Widget build(BuildContext context) {
    final Product product =
        ModalRoute.of(context).settings.arguments as Product;
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: product.imageUrl.isEmpty
                  ? null
                  : Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(height: 10),
            Text(
              'R\$ ${product.price}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                product.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),
            )
          ],
        ),
      ),
    );
  }
}
