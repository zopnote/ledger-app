import 'package:flutter/material.dart';
import 'package:ledger_app/main.dart';

final class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.86,
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: ListView(
          children: [
          ],
        ),
      ),
    );
  }
}
