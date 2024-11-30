import 'package:currensee_convertor_app/theme.dart'; // Import the theme
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String fromCurrency = "USD";
  String toCurrency = "INR";
  List<String> currencyList = [];
  double exchangeRate = 0.0;
  TextEditingController amountController = TextEditingController();
  double convertedAmount = 0.0;
  late User _user;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _getCurrencyData(fromCurrency);
    _getuser();
  }

  void _getuser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        _userEmail = user.uid ?? '';
      });
    }
  }

  Future<void> _getCurrencyData(String baseCurrency) async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/$baseCurrency'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var rates = data['rates'];
      setState(() {
        currencyList = rates.keys.toList();
        exchangeRate = rates[toCurrency] ?? 0.0;
      });
    } else {
      throw Exception("Failed to load currency data");
    }
  }

  void _convertCurrency() {
    setState(() {
      double amount = double.parse(amountController.text);

      convertedAmount = amount * exchangeRate;
    });
  }

  void _convertCurrencybtn() {
    setState(() {
      double amount = double.parse(amountController.text);

      convertedAmount = amount * exchangeRate;

      firestore
          .collection('users')
          .doc(_userEmail)
          .collection('currencyhistory')
          .add({
        'from': fromCurrency,
        'toconvert': toCurrency,
        'amount': amount,
        'Convertedamount': convertedAmount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Use theme background color

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                _convertCurrency();
              },
              controller: amountController,
              cursorColor: AppColors.black,
              decoration: InputDecoration(
                labelText: "Enter amount",
                labelStyle: TextStyle(color: AppColors.black),
                filled: true,
                fillColor: AppColors.primaryColor, // Use theme color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: AppColors.black), // Use theme text color
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            DropdownSearch<String>(
              items: currencyList,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "From Currency",
                  labelStyle: TextStyle(color: AppColors.black),
                  filled: true,
                  fillColor: AppColors.primaryColor, // Use theme color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              selectedItem: fromCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  fromCurrency = newValue!;
                  _getCurrencyData(fromCurrency);
                  _convertCurrency();
                });
              },
              popupProps: PopupProps.menu(
                showSearchBox: true,
              ),
            ),
            SizedBox(height: 20),
            DropdownSearch<String>(
              items: currencyList,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "To Currency",
                  labelStyle: TextStyle(color: AppColors.black),
                  filled: true,
                  fillColor: AppColors.primaryColor, // Use theme color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              selectedItem: toCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  toCurrency = newValue!;
                  _getCurrencyData(fromCurrency);
                  _convertCurrency();
                });
              },
              popupProps: PopupProps.menu(
                showSearchBox: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertCurrencybtn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor, // Use theme color
              ),
              child: Text(
                "Convert",
                style: TextStyle(color: AppColors.white),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Converted Amount: $convertedAmount",
              style: TextStyle(
                fontSize: 20,
                color: AppColors.white, // Use theme text color
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Rate: $exchangeRate",
              style: TextStyle(
                fontSize: 20,
                color: AppColors.white, // Use theme text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
