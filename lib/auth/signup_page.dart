// AiqHK2Sn1ki2pSol
// CRUD

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  final supabase = Supabase.instance.client; //add instance

  double _strength = 0.0;
  String _displayText = "Enter your password";
  Color _progressColor = Colors.grey;

  bool _showPass = true;
  bool _showPass1 = true;
  bool _isAuth = false;

  Future<void> _signUp() async {
    try {
      await supabase.auth.signUp(
        password: _password.text.trim(),
        email: _email.text.trim(),
        data: {
          'username': _username.text.trim(),
        },
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Account Created'),
        backgroundColor: Colors.green,
      ));
      setState(() {
        _isAuth = false;
      });
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _isAuth = false;
      });
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  // Method to check password strength
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _strength = 0;
        _displayText = "Enter your password";
        _progressColor = Colors.grey;
      });
      return;
    }

    // Password strength levels (weak, medium, strong)
    if (password.length < 6) {
      setState(() {
        _strength = 0.3;
        _displayText = "Weak Password";
        _progressColor = Colors.red;
      });
    } else if (password.length >= 6 && password.length < 12) {
      setState(() {
        _strength = 0.6;
        _displayText = "Medium Strength Password";
        _progressColor = Colors.orange;
      });
    } else if (password.length >= 12 &&
        RegExp(r'(?=.*[0-9])(?=.*[a-z])').hasMatch(password)) {
      setState(() {
        _strength = 1.0;
        _displayText = "Strong Password";
        _progressColor = Colors.green;
      });
    } else {
      // Default for passwords with more than 12 characters but no mixed characters
      setState(() {
        _strength = 0.6;
        _displayText = "Medium Strength Password";
        _progressColor = Colors.orange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formkey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: const Text(
                    'SignUp',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: TextFormField(
                    controller: _username,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username cannot be empty';
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: TextFormField(
                    controller: _email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email cannot be empty';
                      }
                      if (!validateEmail(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: TextFormField(
                    onChanged: (password) => _checkPasswordStrength(password),
                    obscureText: _showPass,
                    controller: _password,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      }

                      final passwordError = validatePassword(value);
                      if (passwordError != null) {
                        return passwordError; // Return specific error message
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.password),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showPass = !_showPass;
                          });
                        },
                        icon: Icon(
                          _showPass ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: _strength),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(10),
                        value: value,
                        backgroundColor: Colors.grey[300],
                        color: _progressColor,
                        minHeight: 10,
                      );
                    },
                  ),
                ),
                Container(
                  child: Text(
                    _displayText,
                    style: TextStyle(fontSize: 16, color: _progressColor),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: TextFormField(
                    obscureText: _showPass1,
                    controller: _passwordConfirm,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      }

                      final passwordError = validatePassword(value);
                      if (passwordError != null) {
                        return passwordError; // Return specific error message
                      }

                      if (value != _password.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.password),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showPass1 = !_showPass1;
                          });
                        },
                        icon: Icon(
                          _showPass1 ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  height: 50,
                  margin: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        setState(() {
                          _isAuth = !_isAuth;
                        });
                        _signUp();
                      }
                    },
                    child: (_isAuth)
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Register'),
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  indent: 10,
                  endIndent: 10,
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have account? '),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text('Login'),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool validateEmail(String email) {
    // Basic email validation using a regular expression
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+$",
    );
    return emailRegex.hasMatch(email);
  }

  String? validatePassword(String password) {
    // Check if password is at least 12 characters long
    if (password.length < 12) {
      return 'Password must be at least 12 characters long';
    }

    // Check if password contains at least one symbol
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    // Check if password contains at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    return null; // Password is valid
  }
}
