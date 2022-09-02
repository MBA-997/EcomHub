import 'package:ecomhub/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
      id: DateTime.now().toString(),
      title: '',
      price: 0,
      description: '',
      imageUrl: '');

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImageURL);
    super.initState();
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImageURL);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageFocusNode.dispose();

    super.dispose();
  }

  void _updateImageURL() {
    if (!_imageFocusNode.hasFocus) {
      if ((_imageUrlController.text.isEmpty) ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }

      setState(() {});
    }
  }

  void saveForm() {
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _form.currentState?.save();

    Provider.of<ProductsProvider>(context, listen: false)
        .addProduct(_editedProduct);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Edit Product')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _form,
            autovalidateMode: AutovalidateMode.always,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: DateTime.now().toString(),
                        title: value.toString(),
                        price: _editedProduct.price,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                      );
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide a value';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a price.';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter a number greater than zero';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: DateTime.now().toString(),
                        title: _editedProduct.title,
                        price: value as double,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                      );
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a description';
                      }
                      if (value.length < 10) {
                        return 'Should be at least 10 characters long.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: DateTime.now().toString(),
                        title: _editedProduct.title,
                        price: _editedProduct.price,
                        description: value.toString(),
                        imageUrl: _editedProduct.imageUrl,
                      );
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(
                          top: 8,
                          right: 10,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        )),
                        child: Container(
                          child: _imageUrlController.toString().isEmpty
                              ? const Text('Enter an image URL')
                              : FittedBox(
                                  child: Image.network(
                                  _imageUrlController.toString(),
                                  fit: BoxFit.cover,
                                )),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Image URL'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          focusNode: _imageFocusNode,
                          controller: _imageUrlController,
                          onEditingComplete: () => setState(() {}),
                          onFieldSubmitted: (_) {
                            saveForm();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter an image URL.';
                            }
                            if (!value.startsWith('http') &&
                                !value.startsWith('https')) {
                              return 'Please enter a valid URL.';
                            }
                            if (!value.endsWith('.png') &&
                                !value.endsWith('.jpg') &&
                                !value.endsWith('.jpeg')) {
                              return 'Please enter a valid image URL';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              id: DateTime.now().toString(),
                              title: _editedProduct.title,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: value.toString(),
                            );
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
