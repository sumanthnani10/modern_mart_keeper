import 'package:flutter/material.dart';

class AnimaList extends StatefulWidget {
  @override
  _AnimaListState createState() => _AnimaListState();
}

class _AnimaListState extends State<AnimaList> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  List<Widget> _items = [];
  List<TextEditingController> price_controller =
  new List<TextEditingController>();
  List<TextEditingController> oprice_controller =
  new List<TextEditingController>();
  List<TextEditingController> quan_controller =
  new List<TextEditingController>();
  List<int> prices = new List<int>(),
      oprices = new List<int>(),
      quans = new List<int>();
  List<String> units = new List<String>();
  int count = 1;

  @override
  void initState() {
    super.initState();
    price_controller.add(new TextEditingController());
    oprice_controller.add(new TextEditingController());
    quan_controller.add(new TextEditingController());
    units.add('kg');
    prices.add(0);
    oprices.add(0);
    quans.add(0);
    _items.add(getWidget(0));
  }

  Widget getWidget(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: TextFormField(
              controller: price_controller[index],
              maxLines: 1,
              keyboardType: TextInputType.number,
              validator: (pprice) {
                if (pprice.isEmpty) {
                  return "*Required";
                } else {
                  prices[index] = int.parse(pprice);
                  return null;
                }
              },
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  labelText: 'Price',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  fillColor: Colors.white),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Flexible(
            child: TextFormField(
              controller: oprice_controller[index],
              maxLines: 1,
              keyboardType: TextInputType.number,
              validator: (pprice) {
                if (pprice.isEmpty) {
                  return "*Required";
                } else {
                  oprices[index] = int.parse(pprice);
                  return null;
                }
              },
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  labelText: 'MRP',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  fillColor: Colors.white),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Flexible(
            child: TextFormField(
              controller: quan_controller[index],
              maxLines: 1,
              keyboardType: TextInputType.number,
              validator: (pprice) {
                if (pprice.isEmpty) {
                  return "*Required";
                } else {
                  quans[index] = int.parse(pprice);
                  return null;
                }
              },
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black)),
                  fillColor: Colors.white),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black)),
              child: DropdownButton<String>(
                elevation: 0,
                autofocus: true,
                dropdownColor: Colors.greenAccent,
                iconSize: 16,
                isExpanded: true,
                value: units[index],
                items: <String>['kg', 'grams', 'l', 'ml', 'units']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String value) {
                  setState(() {
                    units[index] = value;
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, animation) {
    Widget item = _items[index];
    return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            child: AnimatedList(
              key: listKey,
              initialItemCount: _items.length,
              itemBuilder: (context, index, animation) {
                return _buildItem(context, index, animation);
              },
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                if (_items.length <= 1) return;
                price_controller.removeLast();
                oprice_controller.removeLast();
                quan_controller.removeLast();
                units.removeLast();
                prices.removeLast();
                oprices.removeLast();
                quans.removeLast();
                listKey.currentState.removeItem(
                    _items.length - 1,
                        (_, animation) =>
                        _buildItem(context, _items.length - 1, animation),
                    duration: const Duration(milliseconds: 500));
                setState(() {
                  _items.removeLast();
                });
              },
              child: Text(
                "Remove",
              ),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  price_controller.add(new TextEditingController());
                  oprice_controller.add(new TextEditingController());
                  quan_controller.add(new TextEditingController());
                  units.add('kg');
                  prices.add(0);
                  oprices.add(0);
                  quans.add(0);
                  listKey.currentState.insertItem(_items.length,
                      duration: const Duration(milliseconds: 500));
                  _items = []
                    ..addAll(_items)
                    ..add(getWidget(_items.length));
                });
              },
              child: Text(
                "Add",
              ),
            ),
          ],
        )
      ],
    );
  }
}
