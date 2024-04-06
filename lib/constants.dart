import 'package:flutter/material.dart';

class CfKeys {
  static String id = ''; //
  static String secretID =
      ''; //
  static String url = "https://sandbox.cashfree.com/pg/orders";
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackbarMessage(
    String text, BuildContext context) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      showCloseIcon: true,
      backgroundColor: Colors.purple,
      closeIconColor: Colors.white,
    ),
  );
}
