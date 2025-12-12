import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Title
              const Text(
                'ClassPal',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Color(0xFF1E1E2D),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Học thật chất, quản lý phất, ClassPal cân tất.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              // Feature grid
              _buildFeatureGrid(),
              const Spacer(flex: 3),
              // Get Started button
              _buildGetStartedButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.check_circle_outline,
                title: 'Duties',
                subtitle: 'Track tasks',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                emoji: '🗓️',
                title: 'Events',
                subtitle: 'RSVP & attend',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                emoji: '💰',
                title: 'Funds',
                subtitle: 'Manage money',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                emoji: '📦',
                title: 'Assets',
                subtitle: 'Borrow items',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    IconData? icon,
    String? emoji,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (icon != null)
            Icon(icon, size: 32, color: const Color(0xFF1E1E2D))
          else if (emoji != null)
            Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E2D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/signin');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4682A9),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Khởi hành',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
