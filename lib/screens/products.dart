import 'dart:math';

import 'package:flutter/material.dart';

import '../containers/product_item.dart';
import '../screens/add_product.dart';
import '../storage.dart';

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<dynamic> visproducts = new List<dynamic>();
  List<String> categories = [
        'All',
      ] +
      Storage.categories;
  String search = '';
  int viewCat = 0;

  ScrollController scrollController = new ScrollController();
  int viewItems = 20;

  TextEditingController search_controller = new TextEditingController();

  double bheight = 80;

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        viewItems += 20;
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(bheight),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: search_controller,
                    maxLines: 1,
                    textInputAction: TextInputAction.search,
                    onChanged: (s) {
                      search = s;
                    },
                    onSubmitted: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                    decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              search_controller.text = '';
                              search = '';
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: search == '' ? Colors.white : Colors.black,
                            size: 16,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        labelStyle: TextStyle(color: Colors.black),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(categories.length, (index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                viewCat = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 1000),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: viewCat == index
                                      ? Colors.black
                                      : Colors.black12),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                categories[index],
                                style: TextStyle(
                                    color: viewCat == index
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 32,
            ),
          ),
          title: Text(
            'Products',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 4,
                  ),
                  if (Storage.productsList.length != 0)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        visproducts = Storage.productsList;
                        visproducts = visproducts.where((e) {
                          if (viewCat == 0) {
                            if (e
                                .data()['n']
                                .toString()
                                .toLowerCase()
                                .contains(search.toLowerCase()))
                              return true;
                            else
                              return false;
                          } else {
                            if (e
                                    .data()['n']
                                    .toString()
                                    .toLowerCase()
                                    .contains(search.toLowerCase()) &&
                                e.data()['c'] == viewCat - 1)
                              return true;
                            else
                              return false;
                          }
                        }).toList();
                        if (visproducts.length != 0) {
                          if (constraints.maxWidth <= 600) {
                            return GridView.count(
                              physics: BouncingScrollPhysics(),
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              childAspectRatio: 0.675,
                              children: List.generate(
                                  min<int>(viewItems, visproducts.length),
                                  (index) {
                                return ProductItem(
                                  snap: visproducts[index],
                                );
                              }),
                            );
                          } else {
                            return GridView.count(
                              physics: BouncingScrollPhysics(),
                              crossAxisCount: 4,
                              shrinkWrap: true,
                              childAspectRatio: 0.65,
                              children: List.generate(
                                  min<int>(viewItems, visproducts.length),
                                  (index) {
                                return ProductItem(
                                  snap: visproducts[index],
                                );
                              }),
                            );
                          }
                        } else {
                          return Center(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text('No Products'),
                          ));
                        }
                      },
                    ),
                  if (Storage.productsList.length == 0)
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text('No Products'),
                    ))
                ],
              ),
            )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (Storage.categories.length != 0) {
              Navigator.of(context).push(createRoute(AddProduct()));
            }
          },
          splashColor: Colors.green,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Route createRoute(dest) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => dest,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0, 1);
        var end = Offset.zero;
        var curve = Curves.fastOutSlowIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
