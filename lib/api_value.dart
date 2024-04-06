import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cf_payment_test_app/constants.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

//-----------------------------------------------------------------//

class CreateOrder {
  Future<dynamic> createOrder(
      String amount, var randomValue, BuildContext context) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'x-client-id': CfKeys.id,
        'x-client-secret': CfKeys.secretID,
        'x-api-version': '2023-08-01',
      };

      var body = jsonEncode({
        "order_amount": amount,
        "order_id": "order_$randomValue",
        "order_currency": "INR",
        "customer_details": {
          "customer_id": randomValue.toString(),
          "customer_phone": '9898787899',
        },
        "order_meta": {"notify_url": "https://test.cashfree.com"}
      });

      http.Response response = await http.post(
        Uri.parse(CfKeys.url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        return data;
      } else {
        dynamic data = response.body;
        return data;
      }
    } catch (e) {
      snackbarMessage(e.toString(), context);
    }
  }
}

//-----------------------------------------------------------------//

class OpenCheckout {
  void openCashfreeCheckout(
    String? cfPaymentSessionId,
    String? orderkiId,
    CFEnvironment environment,
    var cfPaymentGatewayService,
    BuildContext context,
  ) {
    try {
      var createSession = CreateSession();

      var session = createSession.createSession(
          cfPaymentSessionId, orderkiId, environment, context);
      List<CFPaymentModes> components = <CFPaymentModes>[];
      components.add(CFPaymentModes.UPI);
      var paymentComponent =
          CFPaymentComponentBuilder().setComponents(components).build();

      var theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#800080")
          .setPrimaryFont("Menlo")
          .setSecondaryFont("Futura")
          .build();

      var cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(session!)
          .setPaymentComponent(paymentComponent)
          .setTheme(theme)
          .build();

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } on CFException catch (e) {
      snackbarMessage(e.message, context);
    }
  }
}

//-----------------------------------------------------------------//

class CreateSession {
  CFSession? createSession(
    String? cfPaymentSessionId,
    String? orderkiId,
    CFEnvironment environment,
    BuildContext context,
  ) {
    if (cfPaymentSessionId != null) {
      try {
        var session = CFSessionBuilder()
            .setEnvironment(environment)
            .setOrderId("order_$orderkiId")
            .setPaymentSessionId(cfPaymentSessionId)
            .build();
        return session;
      } on CFException catch (e) {
        snackbarMessage(e.message, context);
      }
    } else {
      snackbarMessage('Order details not available', context);
    }
    return null;
  }
}
