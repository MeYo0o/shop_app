import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/provider_orders.dart' show Orders;
import 'package:shop_app/widgets/appDrawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const String id = 'orders_screen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _futureHandler;

  Future<void> _obtainFutureOrders() async {
    await Provider.of<Orders>(context, listen: false).fetchNSetOrders();
  }

  @override
  void initState() {
    //before super.initState
    _futureHandler = _obtainFutureOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Test Print to see if it builds multiple times
    // print('building only once');
    //comment this and use consumer , cuz both are listening and
    // changeNotifiers() will load this screen infinity
    // final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _futureHandler,
        builder: (context, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapShot.error != null) {
              //there is an error , do error handling here
              return Center(
                child: Text('There were an error'),
              );
            } else {
              return Consumer<Orders>(
                builder: (context, ordersData, child) => ListView.builder(
                  itemCount: ordersData.orders.length,
                  itemBuilder: (context, index) =>
                      OrderItem(ordersData.orders[index]),
                ),
              );
            }
          }
        },
      )

      // _isLoading
      //     ? Center(child: CircularProgressIndicator())
      //     : ListView.builder(
      //         itemCount: ordersData.orders.length,
      //         itemBuilder: (context, index) =>
      //             OrderItem(ordersData.orders[index]),
      //       )
      ,
      drawer: AppDrawer(),
    );
  }
}
