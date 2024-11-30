import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:currensee_convertor_app/home.dart';
import 'package:currensee_convertor_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class SetCurrency extends StatefulWidget {
  @override
  _SetCurrencyState createState() => _SetCurrencyState();
}

class _SetCurrencyState extends State<SetCurrency> {
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
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    _getCurrencyData(fromCurrency);
    _getuser();
  }

  triggerNotification() {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basicchanel',
            title: 'Simple notification',
            body: 'simple Body'));
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

  void _convertCurrencybtn() async {
    double amount = double.parse(amountController.text);
    double convertedAmount = amount * exchangeRate;

    final userDocRef =
        firestore.collection('users').doc(_userEmail).collection('Setcurrency');

    final querySnapshot =
        await userDocRef.where('amount', isEqualTo: amount).get();

    if (querySnapshot.docs.isEmpty) {
      await userDocRef.add({
        'from': fromCurrency,
        'toconvert': toCurrency,
        'amount': amount,
        'Convertedamount': convertedAmount,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(
        msg: "Currency conversion added.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      Fluttertoast.showToast(
        msg: "This conversion amount already exists.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Background color applied
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.white, // Set icon color to white
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // The icon you want to display
          onPressed: () {
            Navigator.pushNamed(
                context, '/home'); // Redirect to home when clicked
          },
        ),
        backgroundColor: AppColors.secondaryColor,
        title: Text(
          'Set Rate',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text field for entering the rate
            _buildTextField(
                amountController, "Enter Rate", TextInputType.number),
            SizedBox(height: 20),

            // Dropdown for selecting the 'From' currency
            _buildDropdown(currencyList, "From Currency", fromCurrency,
                (String? newValue) {
              setState(() {
                fromCurrency = newValue!;
                _getCurrencyData(fromCurrency);
                _convertCurrency();
              });
            }),
            SizedBox(height: 20),

            // Dropdown for selecting the 'To' currency
            _buildDropdown(currencyList, "To Currency", toCurrency,
                (String? newValue) {
              setState(() {
                toCurrency = newValue!;
                _getCurrencyData(fromCurrency);
                _convertCurrency();
              });
            }),
            SizedBox(height: 20),

            // Button to set the currency conversion
            ElevatedButton(
              onPressed: _convertCurrencybtn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
              ),
              child: Text(
                "Set",
                style: TextStyle(color: AppColors.white),
              ),
            ),
            SizedBox(height: 25),

            // Button to trigger the notification
            ElevatedButton(
              child: Text("Notification"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              onPressed: triggerNotification,
            ),
            Text("Fetch Data......"),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_userEmail)
                    .collection('Setcurrency')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No data found'));
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      return ListTile(
                        title: Text(
                            '${data['from']} to ${data['toconvert']} - ${data['Convertedamount']}'),
                        subtitle: Text('Amount: ${data['amount']}'),
                        trailing: Text(
                            'Date: ${(data['createdAt'] as Timestamp).toDate()}'),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
         
          ],
        ),
      ),
    );
  }

  // Widget for building text fields
  Widget _buildTextField(TextEditingController controller, String labelText,
      TextInputType keyboardType) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.black),
      cursorColor: AppColors.black,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: AppColors.black),
        filled: true,
        fillColor: AppColors.primaryColor, // Same theme for text fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Widget for building dropdowns
  Widget _buildDropdown(List<String> items, String labelText,
      String selectedItem, ValueChanged<String?> onChanged) {
    return DropdownSearch<String>(
      items: items,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: AppColors.black),
          filled: true,
          fillColor: AppColors.primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      selectedItem: selectedItem,
      onChanged: onChanged,
      popupProps: PopupProps.menu(
        showSearchBox: true,
      ),
    );
  }
}
