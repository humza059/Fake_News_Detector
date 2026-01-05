import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../models/news_article.dart';
import '../core/app_constants.dart';

class NewsDetectionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<NewsArticle> scanNews({
    required String title,
    required String content,
    String? source,
  }) async {
    bool isFake = false;
    double credibilityScore = 0.0;
    List<String> issues = [];

    final Uri apiUrl = Uri.parse(AppConstants.predictionEndpoint);
  
    try {
      debugPrint('Scanning news at: $apiUrl'); // Helpful for debugging
      final response = await http
          .post(
            apiUrl,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': '$title\n$content'}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse "label" which determines if news is FAKE or REAL
        // User's API returns: { "label": "FAKE", "confidence": 0.0067... }
        final dynamic rawLabel = data['label'];
        final String labelStr = rawLabel.toString().toUpperCase();

        // 1 means FAKE in the previous schema, "FAKE" string in the new one
        isFake = (labelStr == 'FAKE' || labelStr == '1');

        final double confidence = (data['confidence'] as num).toDouble();

        // Calculate Credibility Score (0.0 = Fake, 1.0 = Real)
        if (isFake) {
          // If model says FAKE with 90% confidence, Credibility is 10%
          credibilityScore = (1.0 - confidence).clamp(0.0, 1.0);
        } else {
          // If model says REAL with 90% confidence, Credibility is 90%
          credibilityScore = confidence.clamp(0.0, 1.0);
        }

        // Add issues/notes based on prediction
        if (isFake) {
          issues.add('AI Detection flagged this as potential fake news');
          if (confidence > 0.8) {
            issues.add(
              'High confidence AI prediction (Match: ${(confidence * 100).toStringAsFixed(1)}%)',
            );
          }
        } else {
          if (confidence < 0.6) {
            issues.add('AI analysis was inconclusive (Low confidence)');
          }
        }
      } else {
        issues.add(
          'Server verification failed (Status: ${response.statusCode})',
        );
        // Fallback to basic heuristics if server fails?
        // For now, let's mark as inconclusive/verified to avoid false positive fakes.
        credibilityScore = 0.5;
      }
    } catch (e) {
      issues.add('Connection error: Is the backend running at $apiUrl?');
      credibilityScore = 0.5; // Unknown
    }

    // Clamp score
    credibilityScore = credibilityScore.clamp(0.0, 1.0);

    final result = NewsArticle(
      title: title,
      content: content,
      source: source ?? 'Unknown',
      isFake: isFake,
      credibilityScore: credibilityScore,
      scanDate: DateTime.now(),
      issues: issues.isEmpty && isFake
          ? ['Low credibility indicators detected']
          : issues,
      status: isFake ? 'Fake' : 'Verified',
    );

    // Attempt to save to Firestore, but don't block logic if it fails (e.g. permissions)
    try {
      await _saveScanToFirestore(result).timeout(const Duration(seconds: 2));
    } catch (e) {
      // Log error but allow result to be returned to user
      // debugPrint('Failed to save to history: $e');
    }

    return result;
  }

  static Future<void> _saveScanToFirestore(NewsArticle article) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .add(article.toMap());
    }
  }

  static Stream<List<NewsArticle>> getUserScansStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('scanDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NewsArticle.fromMap(doc.data()))
              .toList();
        });
  }
}
