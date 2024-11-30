import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee_convertor_app/theme.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final _feedbackController = TextEditingController();
  final _issueController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Feedback & Report Issues',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: AppColors.white,

      // backgroundColor: Colors.deepPurple[700],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('We value your feedback', context),
              _buildFeedbackForm(),
              SizedBox(height: 20.0),
              _buildSectionTitle('Report an Issue', context),
              _buildIssueForm(),
              SizedBox(height: 20.0),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.black,
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Card(
      color: AppColors.primary2Color,
      // color: Colors.deepPurple[300],
      // color: Colors.deepPurple[500],
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Feedback',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Let us know what you think...',
                hintStyle: TextStyle(color: AppColors.black),
                filled: true,
                // fillColor: Colors.deepPurple[400],
                fillColor: AppColors.primaryColor,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueForm() {
    return Card(
      color: AppColors.primary2Color,
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Describe the Issue',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _issueController,
              maxLines: 4,
              style: TextStyle(color: AppColors.black),
              decoration: InputDecoration(
                hintText: 'Tell us what went wrong...',
                hintStyle: TextStyle(color: AppColors.black),
                filled: true,
                fillColor: AppColors.primaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _submitFeedback(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor,
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
          textStyle: TextStyle(
            color: AppColors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(
          'Submit',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  void _submitFeedback(BuildContext context) async {
    final feedback = _feedbackController.text;
    final issue = _issueController.text;

    if (feedback.isNotEmpty || issue.isNotEmpty) {
      try {
        User? user = _auth.currentUser; // Get the current user
        String userEmail = user?.email ??
            'Anonymous'; // Default to 'Anonymous' if no user is signed in

        await _firestore.collection('feedback').add({
          'feedback': feedback,
          'issue': issue,
          'userEmail': userEmail,
          'timestamp': FieldValue.serverTimestamp(),
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Thank You!'),
              content: Text('Your feedback and issues have been submitted.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _feedbackController.clear();
                    _issueController.clear();
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Handle errors here, such as showing an error message
        print('Error submitting feedback: $e');
      }
    } else {
      // Show an error message if no feedback or issue is provided
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please provide feedback or describe the issue.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
