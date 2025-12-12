import 'package:flutter/material.dart';
import 'package:handyconnect/customer_dashboard.dart';
import 'package:handyconnect/src/providers/user_provider.dart';
import 'package:handyconnect/worker_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup.dart';

// --- Color and Style Constants ---
const Color kPrimaryColor = Color(0xFF4A2E1E);
const Color kSecondaryColor = Color(0xFFC07B4D);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color kFieldColor = Color(0xFFE9DFD8);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Access the Supabase client
  final _supabase = Supabase.instance.client;

  // Function to handle the Supabase login
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Basic input validation
    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // --- SUPABASE LOGIN CALL ---
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Check if widget is still in the tree before using context
      if (!mounted) return;

      // Success Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful! Welcome, ${response.user?.email}'),
          backgroundColor: Colors.green,
        ),
      );

      late Widget landingPage;
      // print("User Role: ${response.user?.}");
      switch (response.user?.role) {
        case 'worker':
          landingPage = WorkerDashboard();
          break;
        case 'customer':
          landingPage = CustomerDashboard();
          break;
        default:
          throw UnimplementedError('There is no landing page for this user role.');
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => landingPage));

    } on AuthException catch (error) {
      // --- HANDLE SUPABASE AUTH ERRORS ---
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message), // e.g. "Invalid login credentials"
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      // --- HANDLE UNEXPECTED ERRORS ---
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Stop loading regardless of success or failure
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        title: const Text(
          "Login",
          style: TextStyle(color: kFieldColor, fontSize: 30),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            // 1. Main Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // minHeight: MediaQuery.of(context).size.height -
                    //     MediaQuery.of(context).padding.top,
                    maxWidth: 600,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 50),

                        // --- Welcome Text ---
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- Email Input ---
                        _buildRoundedInputField(
                          controller: _emailController,
                          hintText: 'Email',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),

                        // --- Password Input ---
                        _buildRoundedInputField(
                          controller: _passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),

                        // --- Forgot Password Link ---
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement Reset Password Logic
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: kSecondaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- Log In Button ---
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 5,
                              shadowColor: kPrimaryColor.withValues(alpha: 0.5),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),

                        // --- Sign Up Link ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to Sign Up Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: kSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Loading Indicator Overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: kPrimaryColor),
                          const SizedBox(height: 15),
                          const Text(
                            "Logging in...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Icon(icon, color: kPrimaryColor),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: kPrimaryColor, width: 2.0),
          ),
        ),
      ),
    );
  }
}
