import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a SafeArea to avoid UI overlapping with system notches or bars
    return Scaffold(
      body: SafeArea(
        child: Container(
          // Full width and height
          width: double.infinity,
          height: double.infinity,
          // Apply a gradient background similar to the design
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A2E), // Dark Blue/Purple
                const Color(0xFF16213E).withOpacity(0.8), // Lighter shade
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for an App Logo
              const Icon(
                Icons.local_hospital,
                size: 80,
                color: Colors.white70,
              ),
              const SizedBox(height: 20),
              const Text(
                'Ebola Response',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Congo Region',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 60),

              // Main action buttons
              _buildActionButton(
                context,
                icon: Icons.chat_bubble_outline,
                label: 'Get Information (Chatbot)',
                onPressed: () {
                  // We will define this route in main.dart
                  Navigator.pushNamed(context, '/chat');
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                icon: Icons.person_add_alt_1,
                label: 'Apply for Medical Team',
                onPressed: () {
                  // We will define this route in main.dart
                  Navigator.pushNamed(context, '/register');
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                icon: Icons.login,
                label: 'Staff Portal Login',
                onPressed: () {
                  // We will define this route in main.dart
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build styled buttons, avoiding code repetition
  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
