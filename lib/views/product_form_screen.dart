import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';

import '../providers/products.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageURLFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageURLFocusNode.addListener(_updateImageURL);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final product = ModalRoute.of(context).settings.arguments as Product;
      if (product != null) {
        _formData['id'] = product.id;
        _formData['titulo'] = product.title;
        _formData['descricao'] = product.description;
        _formData['preco'] = product.price;
        _formData['URLImage'] = product.imageUrl;

        _imageURLController.text = _formData['URLImage'];
      } else {
        _formData['preco'] = '';
      }
    }
  }

  void _updateImageURL() {
    if (isValidImageUrl(_imageURLController.text)) {
      setState(() {});
    }
  }

  bool isValidImageUrl(String url) {
    bool isValidProtocol = url.toLowerCase().startsWith('http://') ||
        url.toLowerCase().startsWith('https://');
    bool endsWithImageExtention = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg');

    return isValidProtocol && endsWithImageExtention;
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLFocusNode.removeListener(_updateImageURL);
    _imageURLFocusNode.dispose();
  }

  Future<void> _saveForm() async {
    bool isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }
    _form.currentState.save();
    Product produto = new Product(
        id: _formData['id'],
        title: _formData['titulo'],
        description: _formData['descricao'],
        price: _formData['preco'],
        imageUrl: _formData['URLImage']);
    setState(() {
      _isLoading = true;
    });

    final products = Provider.of<Products>(context, listen: false);

    try {
      if (_formData['id'] == null) {
        await products.addProduct(produto);
      } else {
        await products.updateProduct(produto);
      }
    } catch (onError) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocorrou um erro!'),
          content: Text(onError.toString()),
          actions: [
            FloatingActionButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário Produto'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                _saveForm();
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _formData['titulo'],
                        decoration: InputDecoration(labelText: 'Título'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (value) => _formData['titulo'] = value,
                        validator: (value) {
                          if (value.trim().isEmpty ||
                              value.trim().length <= 3) {
                            return 'informe um título válido';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['preco'].toString(),
                        decoration: InputDecoration(labelText: 'Preço'),
                        focusNode: _priceFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) =>
                            _formData['preco'] = double.parse(value),
                        validator: (value) {
                          bool vazio = value.trim().isEmpty;
                          var newPrice = double.parse(value);
                          bool invalido = newPrice == null || newPrice <= 0;
                          if (vazio || invalido) {
                            return 'Informe um preço válido';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['descricao'],
                        decoration: InputDecoration(labelText: 'Descrição'),
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        maxLines: 3,
                        onSaved: (value) => _formData['descricao'] = value,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'URL da Imagem'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              focusNode: _imageURLFocusNode,
                              controller: _imageURLController,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onSaved: (value) => _formData['URLImage'] = value,
                              /*
                              validator: (value) {
                                bool vazio = value.trim().isEmpty;
                                bool invalida = isValidImageUrl(value);
                                if (vazio || invalida) {
                            return 'Informe uma URL válida';

                                return null;
                              },}*/
                            ),
                          ),
                          Container(
                            height: 100,
                            width: 100,
                            margin: EdgeInsets.only(
                              top: 15,
                              left: 10,
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            )),
                            alignment: Alignment.center,
                            child: _imageURLController.text.isEmpty
                                ? Text('Informe a URL')
                                : Image.network(
                                    _imageURLController.text,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }
}
