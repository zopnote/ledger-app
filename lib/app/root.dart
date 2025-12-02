import 'package:ledger_app/app/items.dart';
import 'package:ledger_app/app/printer.dart';
import 'package:ledger_app/app/settings.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'checkout.dart';

final Map<String, Widget> pages = {
  "Artikel verbuchen": CheckoutPage(),
  "Artikelregister": ItemsPage(),
  "Drucker": PrinterPage(),
  "Einstellungen": SettingsPage()
};

final class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SidebarXController sidebarController;
  final _key = GlobalKey<ScaffoldState>();
  int selected = 0;
  @override
  void initState() {
    bool initialized = false;
    sidebarController = SidebarXController(selectedIndex: 0, extended: false)
      ..addListener(
        () => setState(() {
          selected = initialized ? sidebarController.selectedIndex : 0;
          initialized = true;
        }),
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          key: _key,
          backgroundColor: backgroundColor,
          drawer: SidebarX(
            controller: sidebarController,
            theme: SidebarXTheme(
              width: 70,
              decoration: BoxDecoration(color: barColor),
              textStyle: TextStyle(color: foregroundColor),
              iconTheme: IconThemeData(color: foregroundColor),
              selectedTextStyle: TextStyle(
                color: primaryColor,
              ),
              selectedIconTheme: IconThemeData(
                color: primaryColor,
              ),
            ),
            showToggleButton: false,
            items: [
              SidebarXItem(icon: Icons.shopping_cart_checkout, label: ""),
              SidebarXItem(icon: Icons.apps, label: ""),
              SidebarXItem(icon: Icons.print, label: ""),
              SidebarXItem(icon: Icons.settings, label: ""),
            ],
          ),
          body: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: barColor,
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: WidgetStatePropertyAll(Size(60, 60)),
                        iconSize: WidgetStatePropertyAll(22),
                        backgroundColor: WidgetStatePropertyAll(barColor),
                        foregroundColor: WidgetStatePropertyAll(foregroundColor),
                        elevation: WidgetStatePropertyAll(0),
                        overlayColor: WidgetStatePropertyAll(Color.from(alpha: 0.0, red: primaryColor.r, green: primaryColor.g, blue: primaryColor.b))
                      ),
                      onPressed: () => _key.currentState?.openDrawer(),
                      child: Icon(Icons.menu),
                    ),
                    Text(pages.keys.elementAt(selected), style: TextStyle(
                      color: foregroundColor,
                      fontSize: 18
                    ),)
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height-120,
                width: MediaQuery.sizeOf(context).width,
                child: pages.values.elementAt(selected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
