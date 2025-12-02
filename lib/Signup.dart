import 'package:flutter/material.dart';
import 'login_screen.dart';  // optional if you want back navigation

// Reuse your color theme
const Color kPrimaryColor = Color(0xFF5E453D);
const Color kSecondaryColor = Color(0xFFC07B4D);
const Color kBackgroundColor = Color(0xFFFBFBFB);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Customer controllers
  final TextEditingController cName = TextEditingController();
  final TextEditingController cEmail = TextEditingController();
  final TextEditingController cPhone = TextEditingController();
  final TextEditingController cPassword = TextEditingController();
  final TextEditingController cConfirm = TextEditingController();

  // Worker controllers
  final TextEditingController wName = TextEditingController();
  final TextEditingController wEmail = TextEditingController();
  final TextEditingController wPhone = TextEditingController();
  final TextEditingController wPassword = TextEditingController();
  final TextEditingController wConfirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

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
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: kSecondaryColor,
          tabs: const [
            Tab(text: "Customer"),
            Tab(text: "Worker"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm(
            name: cName,
            email: cEmail,
            phone: cPhone,
            pass: cPassword,
            confirm: cConfirm,
            role: "Customer",
          ),
          _buildForm(
            name: wName,
            email: wEmail,
            phone: wPhone,
            pass: wPassword,
            confirm: wConfirm,
            role: "Worker",
          ),
        ],
      ),
    );
  }

  Widget _buildForm({
    required TextEditingController name,
    required TextEditingController email,
    required TextEditingController phone,
    required TextEditingController pass,
    required TextEditingController confirm,
    required String role,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        children: [
          _roundedField(controller: name, hint: "Full Name", icon: Icons.person),
          const SizedBox(height: 20),
          _roundedField(controller: email, hint: "Email Address", icon: Icons.email),
          const SizedBox(height: 20),
          _roundedField(controller: phone, hint: "Phone Number", icon: Icons.phone),
          const SizedBox(height: 20),
          _roundedField(controller: pass, hint: "Password", icon: Icons.lock, isPassword: true),
          const SizedBox(height: 20),
          _roundedField(controller: confirm, hint: "Confirm Password", icon: Icons.lock, isPassword: true),
          const SizedBox(height: 35),

          // SIGN UP BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                _validate(role, name, email, phone, pass, confirm);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
              ),
              child: Text(
                "Sign Up as $role",
                style: const TextStyle(
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
                color: kSecondaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        ],
      ),
    );
  }

  // Custom styled input field
  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: kPrimaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  void _validate(
    String role,
    TextEditingController name,
    TextEditingController email,
    TextEditingController phone,
    TextEditingController pass,
    TextEditingController confirm,
  ) {
    if (name.text.isEmpty ||
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
      SnackBar(
        content: Text("$role account created successfully!"),
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
