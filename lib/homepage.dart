import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Color Constants (matching your theme)
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color listTileColor = Color(0xFFad8042);
const Color secondaryTextColor = Color(0xFFBFAB67);
const Color tagsBgColor = Color(0xFFBFC882);
const Color professionColor = Color(0xFFede0d4);
const Color nameColor = Color(0xFFe6ccb2);
const Color accentColor = Color(0xFF8B6F47); // Additional brown accent

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          
          return Stack(
            children: [
              // Background decorative elements
              _buildBackgroundDecoration(),
              
              // Main content
              SafeArea(
                child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPainter(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildHeroSection(),
              const SizedBox(height: 50),
              _buildFeatures(),
              const SizedBox(height: 50),
              _buildCTAButtons(isMobile: true),
              const SizedBox(height: 40),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header with buttons
            _buildDesktopHeader(),
            
            // Hero section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 60),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildHeroSection(),
                  ),
                  const SizedBox(width: 60),
                  Expanded(
                    flex: 4,
                    child: _buildHeroImage(),
                  ),
                ],
              ),
            ),
            
            // Features section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
              color: Colors.white.withValues(alpha: 0.5),
              child: _buildFeatures(),
            ),
            
            // How it works
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
              child: _buildHowItWorks(),
            ),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.handyman, color: kPrimaryColor, size: 32),
              const SizedBox(width: 12),
              Text(
                'HandyConnect',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  // TODO: Navigate to features
                },
                child: Text(
                  'Features',
                  style: TextStyle(color: kPrimaryColor, fontSize: 16),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to how it works
                },
                child: Text(
                  'How It Works',
                  style: TextStyle(color: kPrimaryColor, fontSize: 16),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to about
                },
                child: Text(
                  'About',
                  style: TextStyle(color: kPrimaryColor, fontSize: 16),
                ),
              ),
              const SizedBox(width: 30),
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to login
                  _navigateToLogin();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryColor,
                  side: BorderSide(color: kPrimaryColor, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to signup
                  _navigateToSignup();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.handyman,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Skilled Workers',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
            height: 1.2,
          ),
        ),
        Text(
          'At Your Doorstep',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: accentColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Connect with verified plumbers, electricians, carpenters, and more. Get your work done quickly and professionally.',
          style: TextStyle(
            fontSize: 18,
            color: kPrimaryColor.withValues(alpha: 0.8),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            _buildStatItem('500+', 'Skilled Workers'),
            const SizedBox(width: 40),
            _buildStatItem('10k+', 'Happy Customers'),
            const SizedBox(width: 40),
            _buildStatItem('4.8★', 'Average Rating'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: listTileColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: listTileColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Placeholder for actual image
            Center(
              child: Icon(
                Icons.construction,
                size: 120,
                color: kPrimaryColor.withValues(alpha: 0.3),
              ),
            ),
            // Overlay with worker icons
            Positioned(
              top: 30,
              right: 30,
              child: _buildFloatingIcon(Icons.plumbing, Colors.blue),
            ),
            Positioned(
              bottom: 40,
              left: 40,
              child: _buildFloatingIcon(Icons.electrical_services, Colors.orange),
            ),
            Positioned(
              top: 120,
              left: 50,
              child: _buildFloatingIcon(Icons.carpenter, Colors.brown),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        Text(
          'Why Choose HandyConnect?',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 50),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return Column(
                children: [
                  _buildFeatureCard(
                    Icons.verified_user,
                    'Verified Professionals',
                    'All workers are verified and background-checked for your safety and peace of mind.',
                    Colors.green,
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureCard(
                    Icons.schedule,
                    'Quick Response',
                    'Get responses within minutes and book services at your preferred time.',
                    Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureCard(
                    Icons.star_rate,
                    'Quality Guarantee',
                    'Read reviews and ratings from real customers before making your choice.',
                    Colors.amber,
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureCard(
                    Icons.payment,
                    'Secure Payment',
                    'Pay securely after work completion. Multiple payment options available.',
                    Colors.purple,
                  ),
                ],
              );
            }
            
            return Wrap(
              spacing: 30,
              runSpacing: 30,
              children: [
                SizedBox(
                  width: (constraints.maxWidth - 90) / 4,
                  child: _buildFeatureCard(
                    Icons.verified_user,
                    'Verified Professionals',
                    'All workers are verified and background-checked for your safety.',
                    Colors.green,
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - 90) / 4,
                  child: _buildFeatureCard(
                    Icons.schedule,
                    'Quick Response',
                    'Get responses within minutes and book at your preferred time.',
                    Colors.blue,
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - 90) / 4,
                  child: _buildFeatureCard(
                    Icons.star_rate,
                    'Quality Guarantee',
                    'Read reviews and ratings from real customers before choosing.',
                    Colors.amber,
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - 90) / 4,
                  child: _buildFeatureCard(
                    Icons.payment,
                    'Secure Payment',
                    'Pay securely after work completion. Multiple payment options.',
                    Colors.purple,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: kPrimaryColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      children: [
        Text(
          'How It Works',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStep('1', 'Create Account', 'Sign up as a customer or worker'),
            const Icon(Icons.arrow_forward, color: secondaryTextColor, size: 32),
            _buildStep('2', 'Post or Browse', 'Post job or find customers'),
            const Icon(Icons.arrow_forward, color: secondaryTextColor, size: 32),
            _buildStep('3', 'Get Connected', 'Match with the right person'),
            const Icon(Icons.arrow_forward, color: secondaryTextColor, size: 32),
            _buildStep('4', 'Work & Pay', 'Complete job and payment'),
          ],
        ),
      ],
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: listTileColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButtons({required bool isMobile}) {
    return Column(
      children: [
        SizedBox(
          width: isMobile ? double.infinity : 400,
          height: 56,
          child: ElevatedButton(
            onPressed: _navigateToSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add),
                SizedBox(width: 12),
                Text(
                  'Get Started - Sign Up',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: isMobile ? double.infinity : 400,
          height: 56,
          child: OutlinedButton(
            onPressed: _navigateToLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryColor,
              side: BorderSide(color: kPrimaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login),
                SizedBox(width: 12),
                Text(
                  'Already Have an Account? Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.handyman, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Text(
                'HandyConnect',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Connecting skilled workers with customers since 2024',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Text('  |  ', style: TextStyle(color: Colors.white)),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Text('  |  ', style: TextStyle(color: Colors.white)),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Contact Us',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '© 2024 HandyConnect. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    context.go('/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Login Screen')),
    );
  }

  void _navigateToSignup() {
    context.go('/signup');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Signup Screen')),
    );
  }
}

// Background decoration painter
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw subtle circles in background
    paint.color = const Color(0xFFBFAB67).withValues(alpha: 0.05);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      100,
      paint,
    );
    
    paint.color = const Color(0xFFad8042).withValues(alpha: 0.05);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      150,
      paint,
    );
    
    paint.color = const Color(0xFFBFC882).withValues(alpha: 0.05);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      80,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}