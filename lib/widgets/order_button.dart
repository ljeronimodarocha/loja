import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/orders.dart';

class OrderButtonn extends StatefulWidget {
  const OrderButtonn(this.cart);

  @override
  State<OrderButtonn> createState() => _OrderButtonnState();

  final Cart cart;
}

class _OrderButtonnState extends State<OrderButtonn> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _isLoading
          ? CircularProgressIndicator(
              backgroundColor: Colors.white,
            )
          : Text(
              'COMPRAR',
              style: TextStyle(color: Colors.white),
            ),
      style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary),
      onPressed: widget.cart.totalAmount == 0
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false)
                  .addOrder(widget.cart);
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
    );
  }
}
