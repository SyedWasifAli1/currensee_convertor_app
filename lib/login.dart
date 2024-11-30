import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee_convertor_app/home.dart';
import 'package:currensee_convertor_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true; // Track if user is on the login or sign-up page

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 3), // Duration of the animation
      vsync: this,
    );

    // Animation for scaling
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Start the animation
    _controller.forward();
  }

  // @override
  // void dispose() {
  //   _controller.dispose(); // Dispose controller when the widget is removed
  //   super.dispose();
  // }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Gmail-specific validation
  bool _isGmail(String email) {
    final RegExp gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return gmailRegex.hasMatch(email);
  }

  Future<void> _authenticateUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, return and show the error
      return;
    }

    try {
      if (_isLogin) {
        // Log in user
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        final DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        String role = userDoc['role'];

        Fluttertoast.showToast(
            msg: "Login Successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);

        // Navigate to appropriate screen based on role
        if (role == 'admin') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        } else if (role == 'user') {
          Navigator.pushNamed(context, '/home');
        }
      } else {
        // Sign up user
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        // Add role (e.g., 'user' by default) to Firestore for the newly created user
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'role': 'user', // Assign default role 'user'
          'createdAt': FieldValue
              .serverTimestamp(), // Optionally store account creation time
        });

        Fluttertoast.showToast(
            msg: "Account Created Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);

        // After signing up, navigate the user to the Home screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      }
    } catch (e) {
      String errorMessage = 'An unknown error occurred';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address.';
            break;
          case 'user-disabled':
            errorMessage = 'User account has been disabled.';
            break;
          default:
            errorMessage = e.message ?? 'An unknown error occurred.';
        }
      }
      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Set background color
      // appBar: AppBar(
      //   title: Text(
      //     _isLogin ? 'Login' : 'Sign Up',
      //     style: TextStyle(color: AppColors.white),
      //   ),
      //   backgroundColor: AppColors.secondaryColor, // Set AppBar color
      // ),
      body: Form(
        key: _formKey, // Wrap with Form widget to enable validation
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Center(
                child: ScaleTransition(
                  scale: _animation, // Use the animation for scaling
                  child: Icon(
                    Icons.account_circle_rounded,
                    size: 200.0, // Large icon size
                    color: Colors.grey,
                  ),
                ),
              ),
              _buildTextField(_emailController, 'Email', false),
              SizedBox(height: 20.0),
              _buildTextField(_passwordController, 'Password', true),
              SizedBox(height: 20.0),
              _buildSubmitButton(),
              SizedBox(height: 20.0),
              _buildSwitchAuthButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, bool obscureText) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: AppColors.black,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: AppColors.primaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      // Add Gmail validation for the email field
      validator: (value) {
        if (labelText == 'Email' && (value == null || value.isEmpty)) {
          return 'Please enter an email';
        } else if (labelText == 'Email' && !_isGmail(value!)) {
          return 'Please enter a valid Gmail address (example@gmail.com)';
        } else if (labelText == 'Password' &&
            (value == null || value.isEmpty)) {
          return 'Please enter a password';
        } else if (labelText == 'Password' && value!.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _authenticateUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor,
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
          textStyle: TextStyle(
            // color: AppColors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(
          _isLogin ? 'Login' : 'Sign Up',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchAuthButton() {
    return Center(
      child: TextButton(
        onPressed: _toggleAuthMode,
        child: Text(
          _isLogin
              ? 'Don\'t have an account? Sign Up'
              : 'Already have an account? Login',
          style: TextStyle(color: AppColors.black),
        ),
      ),
    );
  }
}
