import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer to navigate after 5 seconds (reduced from 5 for faster UX)
    Timer(const Duration(seconds: 5), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is logged in, go to Home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // User is not logged in, go to Login
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0A0E21,
      ), // Matches your login/signup background
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF1D2671), Color(0xFF0A0E21)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Centered High-Tech Animation
            SizedBox(
              height: 300,
              child: Lottie.asset(
                'assets/animations/splash_animation.json',
              ),
            ),
            const SizedBox(height: 30),
            // Title with Orbitron Font
            Text(
              textAlign: TextAlign.center,
              "FAKE NEWS DETECTOR",
              style: GoogleFonts.orbitron(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Subtitle with Poppins
            Text(
              "AI-POWERED NEWS VERIFICATION",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
                color: Colors.blueAccent.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 50),
            // Minimalist Loading Indicator
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
