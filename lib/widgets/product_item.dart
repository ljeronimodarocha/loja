import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            product.imageUrl.isEmpty ? null : NetworkImage(product.imageUrl),
      ),
      title: Text(product.title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.PRODUCT_FORM,
                  arguments: product,
                );
              },
              icon: const Icon(Icons.edit),
              color: Theme.of(context).colorScheme.primary,
            ),
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: const Text('Excluir Produto'),
                          content: const Text('Tem certeza?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Não')),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Sim')),
                          ],
                        )).then((value) async {
                  try {
                    await Provider.of<Products>(context, listen: false)
                        .deleteProduct(product.id);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())));
                  }
                });
              },
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
