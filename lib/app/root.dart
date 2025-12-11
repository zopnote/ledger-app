import 'package:ledger_app/app/items.dart';
import 'package:ledger_app/app/printer.dart';
import 'package:ledger_app/app/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'checkout.dart';

final class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  late final Map<String, Widget> pages;

  late final SidebarXController sidebarController;

  final _key = GlobalKey<ScaffoldState>();

  int selected = 0;

  bool loaded = false;

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    pages = {
      "Artikel verbuchen": CheckoutPage(),
      "Artikelregister": ItemsPage(prefs: prefs),
      "Drucker": PrinterPage(),
      "Einstellungen": SettingsPage(prefs: prefs),
    };
    setState(() => loaded = true);
  }

  @override
  void initState() {
    loadPreferences();
    bool initialized = false;
    sidebarController = SidebarXController(selectedIndex: 0, extended: false);
    sidebarController.addListener(
      () => setState(() {
        selected = initialized ? sidebarController.selectedIndex : 0;
        initialized = true;
      }),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return SizedBox();
    }
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
              selectedTextStyle: TextStyle(color: primaryColor),
              selectedIconTheme: IconThemeData(color: primaryColor),
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
                height: 50,
                decoration: BoxDecoration(color: barColor),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: WidgetStatePropertyAll(Size(60, 60)),
                        iconSize: WidgetStatePropertyAll(22),
                        backgroundColor: WidgetStatePropertyAll(barColor),
                        foregroundColor: WidgetStatePropertyAll(
                          foregroundColor,
                        ),
                        elevation: WidgetStatePropertyAll(0),
                        overlayColor: WidgetStatePropertyAll(
                          Color.from(
                            alpha: 0.0,
                            red: primaryColor.r,
                            green: primaryColor.g,
                            blue: primaryColor.b,
                          ),
                        ),
                      ),
                      onPressed: () => _key.currentState?.openDrawer(),
                      child: Icon(Icons.menu),
                    ),
                    Text(
                      pages.keys.elementAt(selected),
                      style: TextStyle(color: foregroundColor, fontSize: 18),
                    ),
                  ],
                ),
              ),
              pages.values.elementAt(selected),
            ],
          ),
        ),
      ),
    );
  }
}
