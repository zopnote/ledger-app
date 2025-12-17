import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ledger_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Item {
  final String name;
  final double price;
  const Item({required this.name, required this.price});
}

final class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key, required this.prefs});

  final SharedPreferences prefs;
  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  bool loaded = false;
  List<Item> items = [];
  late final TextEditingController controllerName;
  late final TextEditingController controllerPrice;

  @override
  void initState() {
    controllerName = TextEditingController();
    controllerPrice = TextEditingController();
    reload();
    super.initState();
  }

  /// ```
  /// String registered_items =
  /// {
  ///   "items": [
  ///     {"name": "Anfahrt", "price": 10.0},
  ///     {"name": "Reperatur Typ 1", "price": 20.0},
  ///   ]
  /// }
  /// ```

  final String prefKey = "reg_item_map";
  Future<void> reload() async {
    String? jsonString = widget.prefs.getString(prefKey);

    if (jsonString == null) {
      setState(() => loaded = true);
      return;
    }

    late final List<Map<String, String>> itemsJson;

    try {
      /// TODO: ERROR HERE
      itemsJson = jsonDecode(jsonString)["items"];
    } catch (e) {
      await widget.prefs.setString(
        prefKey,
        jsonEncode({
          "items": [{}],
        }),
      );
      reload();
      return;
    }

    if (itemsJson.isEmpty) {
      setState(() => loaded = true);
      return;
    }

    for (Map<String, dynamic> map in itemsJson) {
      items.add(Item(name: map["name"], price: map["price"]));
    }

    setState(() => loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return Center(
        child: Text("Lade...", style: TextStyle(color: foregroundColor)),
      );
    }
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.86,
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children:
              <Widget>[
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.75,
                  height: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: buttonStyle(Size(206, 40)),
                        onPressed: () async {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => dialog(),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.add, size: 25),
                            Text(
                              "Artikel hinzufügen",
                              style: TextStyle(
                                color: foregroundColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${items.length} Artikel",
                        style: TextStyle(color: foregroundColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ] +
              List.generate(items.length, (index) {
                return Container(
                  width: 40,
                  color: Colors.red,
                  child: Text(items[index].name),
                );
              }),
        ),
      ),
    );
  }

  ButtonStyle buttonStyle(Size size) => ButtonStyle(
    overlayColor: WidgetStatePropertyAll(Colors.transparent),
    backgroundColor: WidgetStatePropertyAll(backgroundColor),
    foregroundColor: WidgetStatePropertyAll(foregroundColor),
    elevation: WidgetStatePropertyAll(0),
    fixedSize: WidgetStatePropertyAll(size),
  );

  Widget dialog() => AlertDialog(
    backgroundColor: Colors.transparent,
    content: Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: backgroundColor,
        ),
        width: 600,
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: 600,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 30),
                  Text(
                    "Artikel hinzufügen",
                    style: TextStyle(color: foregroundColor, fontSize: 16),
                  ),
                  SizedBox(width: 55),
                  ElevatedButton(
                    style: buttonStyle(Size(40, 40)),
                    onPressed: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 25, color: foregroundColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            textField(controllerName, "Name"),
            textField(controllerPrice, "Preis"),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                border: Border.all(width: 2, color: primaryColor),
              ),
              child: ElevatedButton(
                style: buttonStyle(Size(130, 40)),
                onPressed: () => addItem(controllerName.text, controllerPrice.text),
                child: Text(
                  "Speichern",
                  style: TextStyle(color: foregroundColor, fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 0),
          ],
        ),
      ),
    ),
  );

  void addItem(String nameText, String priceText) {
    final double price;
    try {
      price = double.parse(priceText);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => Container(
          height: 120,
          width: 400,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Center(
            child: Text(
              "Preis ist keine gültige Floating-Point-Zahl.",
              style: TextStyle(color: foregroundColor, fontSize: 16),
            ),
          ),
        ),
      );
      return;
    }

    widget.prefs.setString(
      prefKey,
      jsonEncode({
        "items":
            List.generate(
              items.length,
              (index) => {
                "name": items[index].name,
                "price": items[index].price,
              },
            ) +
            [
              {"name": nameText, "price": price},
            ],
      }),
    );
    Navigator.pop(context);
    controllerName.text = "";
    controllerPrice.text = "";
    reload();
  }

  Widget textField(TextEditingController controller, String labelText) =>
      SizedBox(
        width: 250,
        child: TextField(
          controller: controller,
          cursorColor: primaryColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroundColor,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            contentPadding: EdgeInsets.all(6),
            labelStyle: TextStyle(color: foregroundColor.withAlpha(150)),
            focusColor: primaryColor,
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            labelText: labelText,
          ),
          autocorrect: false,
          style: TextStyle(color: foregroundColor),
        ),
      );
}
