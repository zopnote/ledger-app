import 'package:flutter/material.dart';
import 'package:ledger_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.prefs});

  final SharedPreferences prefs;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool loaded = false;

  @override
  void initState() {
    load();
    super.initState();
  }

  final String prefsKey = "business_name";
  Future<void> load() async {
    widget.prefs.get(prefsKey);
    setState(() => loaded = true);
  }

  final Map<String, String> moneyOptions = const {
    "tax_id": "USt-ID",
    "tax_share": "Umsatzsteuer (in %)",
    "currency": "Währung (Kürzel)",
  };

  final Map<String, String> businessOptions = const {
    "business_name": "Name",
    "business_address_primary": "Adresszeile 1",
    "business_address_secondary": "Adresszeile 2",
    "business_mail": "Mail",
    "business_phone": "Telefon",
    "business_tax_id": "USt-ID",
  };

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
              getSettingsList(businessOptions, "Unternehmensdaten") +
              getSettingsList(moneyOptions, "Finanzdaten"),
        ),
      ),
    );
  }

  List<Widget> getSettingsList(Map<String, String> input, String title) =>
      [
        SizedBox(height: 25),
        Text(title, style: TextStyle(fontSize: 28, color: foregroundColor)),
        SizedBox(height: 15),
      ] +
      List.generate(input.length, (index) {
        return TextFieldSetting(
          name: input[input.keys.elementAt(index)]!,
          save: (newValue) =>
              widget.prefs.setString(input.keys.elementAt(index), newValue),
          value: widget.prefs.getString(input.keys.elementAt(index)),
        );
      });
}

final class TextFieldSetting extends StatefulWidget {
  const TextFieldSetting({
    super.key,
    required this.name,
    this.value,
    required this.save,
  });

  final String name;

  final String? value;

  final Function(String value) save;

  @override
  State<TextFieldSetting> createState() => _TextFieldSettingState();
}

class _TextFieldSettingState extends State<TextFieldSetting> {
  late final TextEditingController controller;

  bool saved = false;

  @override
  void initState() {
    controller = TextEditingController(text: widget.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    width: MediaQuery.sizeOf(context).width,
    child: Row(
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width * (2 / 3),
          child: Theme(
            data: ThemeData(
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.blue,
                selectionColor: Color(0x448AB4F8),
                selectionHandleColor: Colors.blue,
              ),
            ),
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
                labelText: widget.name,
              ),
              autocorrect: false,
              style: TextStyle(color: foregroundColor),
            ),
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            backgroundColor: WidgetStatePropertyAll(backgroundColor),
            foregroundColor: WidgetStatePropertyAll(foregroundColor),
            elevation: WidgetStatePropertyAll(0),
          ),
          onPressed: () async {
            widget.save(controller.text);
            setState(() => saved = true);
            await Future.delayed(Duration(milliseconds: 1500));
            setState(() => saved = false);
          },
          child: Icon(saved ? Icons.check : Icons.save),
        ),
      ],
    ),
  );
}
