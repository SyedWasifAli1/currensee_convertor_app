import 'package:currensee_convertor_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConversionHistoryScreen extends StatefulWidget {
  const ConversionHistoryScreen({super.key});

  @override
  State<ConversionHistoryScreen> createState() =>
      _ConversionHistoryScreenState();
}

class _ConversionHistoryScreenState extends State<ConversionHistoryScreen> {
  late User _user;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Set background color

      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(_userEmail)
              .collection('currencyhistory')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No data found',
                  style: TextStyle(
                    color: Colors.white, // Text color to match the theme
                    fontSize: 18.0,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return Card(
                  color: AppColors.primaryColor, // Card color
                  child: ListTile(
                    title: Text(
                      '${data['from']} to ${data['toconvert']} - ${data['Convertedamount']}',
                      style: TextStyle(
                        color: AppColors.black, // White text color
                      ),
                    ),
                    subtitle: Text(
                      'Amount: ${data['amount']}',
                      style: TextStyle(
                        color: AppColors
                            .primary2Color, // Slightly lighter for subtitle
                      ),
                    ),
                    trailing: Text(
                      'Date: ${(data['createdAt'] as Timestamp).toDate()}',
                      style: TextStyle(
                        color: AppColors.black, // Slightly lighter for date
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
