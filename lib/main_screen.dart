import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var cfPaymentGatewayService = CFPaymentGatewayService();
  CFEnvironment environment = CFEnvironment.SANDBOX;
  String selectedId = "";
  String? cfOrderId;
  String? cfPaymentSessionId;
  String orderkiId = '';

  Future<void> createCashfreeOrder(double amount) async {
    // Add randomness for testing purposes
    var randomValue = DateTime.now().millisecondsSinceEpoch.toString();
    orderkiId = randomValue;

    var headers = {
      'Content-Type': 'application/json',
      'x-client-id': '1372170c8021c61f5dd39c9dbf712731',
      'x-client-secret': 'TEST1bf6b0547b4f6eb9aebad6b8ac7465f5bc0ca2',
      'x-api-version': '2022-09-01',
    };

    var body = jsonEncode({
      "order_amount": amount,
      "order_id": "order_$randomValue",
      "order_currency": "INR",
      "customer_details": {
        "customer_id": "7112AAA812234",
        "customer_email": "johny@cashfree.com",
        "customer_phone": "9898989898"
      },
      "order_meta": {"notify_url": "https://test.cashfree.com"}
    });

    var response = await http.post(
      Uri.parse('https://sandbox.cashfree.com/pg/orders'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      cfOrderId = data['cf_order_id'].toString();
      cfPaymentSessionId = data['payment_session_id'];
    } else {
      // Handle the error or exception
      print('Error while creating order: ${response.body}');
    }
  }

  CFSession? createSession() {
    if (cfPaymentSessionId != null) {
      try {
        var session = CFSessionBuilder()
            .setEnvironment(environment)
            .setOrderId("order_$orderkiId")
            .setPaymentSessionId(cfPaymentSessionId!)
            .build();
        return session;
      } on CFException catch (e) {
        print(e.message);
      }
    } else {
      print('Order details not available');
    }
    return null;
  }

  pay() async {
    try {
      var session = createSession();
      List<CFPaymentModes> components = <CFPaymentModes>[];
      components.add(CFPaymentModes.UPI);
      var paymentComponent =
          CFPaymentComponentBuilder().setComponents(components).build();

      var theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#FF0000")
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
      print(e.message);
    }
  }

  @override
  void initState() {
    super.initState();
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
  }

  void verifyPayment(String orderId) {
    print("Verify Payment");
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Verify Payment")));
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    print('===========${errorResponse.getMessage()}=======');
    print("Error while making payment");
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Payment failed")));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('Amount paying = 100'),
              Center(
                child: TextButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.black),
                        elevation: MaterialStatePropertyAll(20)),
                    onPressed: () async {
                      await createCashfreeOrder(100);
                      pay();
                    },
                    child: const Text(
                      "Pay",
                      style: TextStyle(fontSize: 25),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
