import 'package:flutter/material.dart';
import 'login_screen.dart';

// NEW THEME COLORS
const Color kPrimaryColor = Color(0xFF4A2E1E);        // buttons + headings
const Color kFieldColor = Color(0xFFE9DFD8);          // input backgrounds
const Color kBackgroundColor = Color(0xFFF7F2EF);     // main background

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController fName = TextEditingController();
  final TextEditingController lName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final TextEditingController confirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          children: [
            _roundedField(
              controller: fName,
              hint: "First Name",
              icon: Icons.person,
            ),
            const SizedBox(height: 20),

            _roundedField(
              controller: lName,
              hint: "Last Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            _roundedField(
              controller: email,
              hint: "Email Address",
              icon: Icons.email,
            ),
            const SizedBox(height: 20),

            _roundedField(
              controller: phone,
              hint: "Phone Number",
              icon: Icons.phone,
            ),
            const SizedBox(height: 20),

            _roundedField(
              controller: pass,
              hint: "Password",
              icon: Icons.lock,
              isPassword: true,
            ),
            const SizedBox(height: 20),

            _roundedField(
              controller: confirm,
              hint: "Confirm Password",
              icon: Icons.lock,
              isPassword: true,
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _validate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Already have an account? Log In",
                style: TextStyle(
                  color: kPrimaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kFieldColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: kPrimaryColor.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: kPrimaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  void _validate() {
    if (fName.text.isEmpty ||
        lName.text.isEmpty ||
        email.text.isEmpty ||
        phone.text.isEmpty ||
        pass.text.isEmpty ||
        confirm.text.isEmpty) {
      _showError("Please fill all fields.");
      return;
    }

    if (pass.text != confirm.text) {
      _showError("Passwords do not match.");
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Account created successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }
}
