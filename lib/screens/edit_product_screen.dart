import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/provider_product.dart';
import 'package:shop_app/models/provider_products.dart';

class EditProductScreen extends StatefulWidget {
  static const String id = 'edit_product_screen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _imageUrlFocusNode = FocusNode();
  final TextEditingController _imageUrlController = TextEditingController();
  Product _editedProduct = Product(
    productId: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );

  //so we initialize the TextFormFields with default values
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    // 'imageUrl': '',
  };

  //so we can run the didChangeDependencies func code for
  // first time only when initState runs
  var _isInit = true;

  @override
  void didChangeDependencies() {
    ///To get the values of the selected product for editing , so u can find
    ///all values ready and found in it's places as TextFormFields
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false).filterById(productId);

        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl,
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    ///Validate the form
    final _isValid = _formKey.currentState.validate();
    if (_isValid) {
      return;
    }

    ///Start Loading Indicator
    _startLoading();

    /// else , it will save the form along with rest of code
    _formKey.currentState.save();
    //if the productId has a value , then i'm editing ,
    // i shouldn't save the product as new one but update it's exiting value
    if (_editedProduct.productId != null) {
      ///in case of editing an existed product
      ///passing updateType ==0 to make it update everything except
      /// isFavorite status
      await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.productId, _editedProduct).then((value) {
        ///Stop Indicator
        _stopLoading();

        ///Exit the page after adding the product
        ///Update : make it pops once the future func. is already executed
        Navigator.pop(context);
      });
    } else {
      try {
        await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
      } catch (error) {
        ///handle the error throw from the last method
        await showDialog<Null>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('An Error Occurred'),
                content: Text('Something Went Wrong'),
                actions: [
                  ElevatedButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              );
            });
      }

      ///After catching the error and handling it
      ///also can be executed if no errors were occurred , in case the 1st
      ///Future method were successfully executed
       finally {
        ///Stop Indicator
        _stopLoading();

        ///Exit the page after adding the product
        ///Update : make it pops once the future func. is already executed
        Navigator.pop(context);
      }
      // ///Stop Indicator
      // _stopLoading();
      // Navigator.pop(context);
    }
  }

  ///Circle Loading Indicator
  bool _isLoading = false;

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(hintText: 'Title'),
                        initialValue: _initValues['title'],
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Provide a Title.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) => FocusScope.of(context).requestFocus(_priceFocusNode),
                        onSaved: (value) {
                          _editedProduct = Product(
                              productId: _editedProduct.productId,
                              isFavorite: _editedProduct.isFavorite,
                              title: value,
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              price: _editedProduct.price);
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(hintText: 'Price'),
                        initialValue: _initValues['price'],
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Enter a Price.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please Enter a Valid number.';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Price can\'t be equal or lower than Zero.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) => FocusScope.of(context).requestFocus(_descriptionFocusNode),
                        onSaved: (value) {
                          _editedProduct = Product(
                              productId: _editedProduct.productId,
                              isFavorite: _editedProduct.isFavorite,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              price: double.parse(value));
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(hintText: 'Description'),
                        initialValue: _initValues['description'],
                        focusNode: _descriptionFocusNode,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Enter a Product Description.';
                          }
                          if (value.length < 10) {
                            return 'Please Enter at lease 10 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              productId: _editedProduct.productId,
                              isFavorite: _editedProduct.isFavorite,
                              title: _editedProduct.title,
                              description: value,
                              imageUrl: _editedProduct.imageUrl,
                              price: _editedProduct.price);
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? Center(child: Text('Enter a URL'))
                                : Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(_imageUrlController.text),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            initialValue: _initValues['imageUrl'],
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageUrlFocusNode,
                            controller: _imageUrlController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter an Image Url.';
                              }
                              if (value.startsWith('http') && value.startsWith('https')) {
                                return 'Please Enter a Valid URL.';
                              }
                              if (value.endsWith('.png') && value.endsWith('.jpg') && value.endsWith('.jpeg')) {
                                return 'Please Enter a Valid Image URl.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                  productId: _editedProduct.productId,
                                  isFavorite: _editedProduct.isFavorite,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  imageUrl: value,
                                  price: _editedProduct.price);
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onEditingComplete: () {
                              setState(() {});
                            },
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
