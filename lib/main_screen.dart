// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cf_payment_test_app/constants.dart';
import 'package:cf_payment_test_app/api_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool isLoading = false;

  var cfPaymentGatewayService = CFPaymentGatewayService();
  CFEnvironment environment = CFEnvironment.SANDBOX;
  String? cfOrderId;
  String? cfPaymentSessionId;
  String orderkiId = '';

  var createOrder = CreateOrder();
  var opencheckout = OpenCheckout();

  @override
  void initState() {
    super.initState();
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
  }

  Future<void> createCashfreeOrder(double amount) async {
    var randomValue = DateTime.now().millisecondsSinceEpoch.toString();
    orderkiId = randomValue;

    var response = await createOrder.createOrder(
        _amountController.text, randomValue, context);

    String check = response.toString();

    if (check.contains('cf_order_id')) {
      var data = response;
      cfOrderId = data['cf_order_id'].toString();
      cfPaymentSessionId = data['payment_session_id'];

      opencheckout.openCashfreeCheckout(cfPaymentSessionId, orderkiId,
          environment, cfPaymentGatewayService, context);
    } else {
      var responseError = jsonDecode(response);
      setState(() {
        isLoading = false;
      });
      snackbarMessage(
          "Error while creating order: ${responseError['message']}", context);
    }
  }

  void verifyPayment(String orderId) {
    setState(() {
      isLoading = false;
      _amountController.clear();
    });
    snackbarMessage("Payment Successful", context);
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    setState(() {
      isLoading = false;
      _amountController.clear();
    });
    snackbarMessage(errorResponse.getMessage().toString(), context);
    snackbarMessage("Error while making payment\nPayment failed", context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image(
              image: const AssetImage('assets/image1.png'),
              width: size.width * 0.3,
              fit: BoxFit.contain,
            ),
          ),
        ],
        title: const Text(
          'CF PAYMENT TEST',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: size.height,
          width: size.width,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                  padding: EdgeInsets.only(left: 10, top: 30),
                  child: Text('Enter Amount: (₹)',
                      style: TextStyle(fontSize: 14, color: Colors.black))),
              Container(
                  height: size.height * 0.055,
                  width: size.width,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 2,
                            spreadRadius: 2,
                            color: Colors.grey.shade300,
                            offset: const Offset(1, 1))
                      ]),
                  child: TextField(
                    controller: _amountController,
                    cursorColor: Colors.purple,
                    decoration: const InputDecoration(border: InputBorder.none),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                  )),
              const Spacer(),
              Center(
                  child: GestureDetector(
                      onTap:
                          //  isLoading
                          //     ? null
                          //     :
                          () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (_amountController.text != '0' &&
                            _amountController.text.isNotEmpty) {
                          await createCashfreeOrder(
                              double.parse(_amountController.text));
                          setState(() {
                            isLoading = false;
                          });
                        } else {
                          setState(() {
                            isLoading = false;
                          });

                          snackbarMessage(
                              'Amount must be greater than 0', context);
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Container(
                          height: 40,
                          width: 120,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.purple,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 2,
                                    color: Colors.grey.shade400,
                                    offset: const Offset(1, 1),
                                    spreadRadius: 1)
                              ]),
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 50),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Text("Pay",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                )))),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
