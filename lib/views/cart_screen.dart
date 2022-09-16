import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/widgets/cart_item_widget.dart';

import '../providers/cart.dart';
import '../widgets/order_button.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Cart cart = Provider.of<Cart>(context);
    final List<CartItem> cartItems = cart.items.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(25),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Chip(
                    label: Text(
                      'R\$ ${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium
                            .color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  Spacer(),
                  OrderButtonn(cart),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
                itemCount: cart.itemsCount,
                itemBuilder: (ctx, index) => CartItemWidget(cartItems[index])),
          )
        ],
      ),
    );
  }
}
