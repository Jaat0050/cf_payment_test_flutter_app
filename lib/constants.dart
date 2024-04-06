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

//---------------------------------
//cfsk
//_ma_
//test_
//21c0e91a72bf4d67
//4a3017baac95f200
//_b51af99f

//---------------------------------
//TEST
//1372177e9d394561
//bc86cb4276712731