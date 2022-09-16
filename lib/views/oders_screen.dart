import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/widgets/order_widget.dart';

import '../providers/orders.dart';
import '../widgets/app_drawer.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        centerTitle: true,
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).loadOrders(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return Center(
              child: const Text("Ocorreu um erro!"),
            );
          } else {
            return Consumer<Orders>(
              builder: (ctx, orders, child) {
                return RefreshIndicator(
                  onRefresh: () =>
                      Provider.of<Orders>(context, listen: false).loadOrders(),
                  child: ListView.builder(
                    itemCount: orders.ordersCount,
                    itemBuilder: (ctx, index) =>
                        OrderWidget(orders.items[index]),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
