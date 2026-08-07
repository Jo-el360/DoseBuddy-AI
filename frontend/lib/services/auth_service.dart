import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/user_profile.dart';

class AuthService with ChangeNotifier {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  bool _isAuthenticated = true; // Default logged in for smooth demo/testing
  String? _authToken = "mock_token_123";
  UserProfile? _currentUserProfile = UserProfile(
    userId: "mock-elderly-user-123",
    email: "patient@example.com",
    fullName: "Arthur Pendelton",
    role: "User",
    onboarded: true,
    age: 72,
    gender: "Male",
    bloodGroup: "O+",
    medicalConditions: ["Type 2 Diabetes", "Hypertension"],
    allergies: ["Penicillin"],
    routinePersona: "Senior Citizen",
    emergencyContact: "+15550192834",
    caregiverContact: "sarah.caregiver@example.com",
    adherencePercentage: 94.5,
    createdAt: "2026-01-01T08:00:00",
  );

  bool get isAuthenticated => _isAuthenticated;
  String? get authToken => _authToken;
  UserProfile? get currentUserProfile => _currentUserProfile;
  String get userRole => _currentUserProfile?.role ?? "User";

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['access_token'];
        _currentUserProfile = UserProfile.fromJson(data['user']);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error during login: $e');
    }

    // Mock fallback login success
    _isAuthenticated = true;
    _currentUserProfile = UserProfile(
      userId: "usr-${email.split('@')[0]}",
      email: email,
      fullName: email.split('@')[0].toUpperCase(),
      role: "User",
      onboarded: true,
      medicalConditions: ["Type 2 Diabetes"],
      allergies: [],
      routinePersona: "Senior Citizen",
      adherencePercentage: 100.0,
      createdAt: DateTime.now().toIso8601String(),
    );
    notifyListeners();
    return true;
  }

  Future<bool> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'role': role,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['access_token'];
        _currentUserProfile = UserProfile.fromJson(data['user']);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error during registration: $e');
    }

    _isAuthenticated = true;
    _currentUserProfile = UserProfile(
      userId: "usr-reg-123",
      email: email,
      fullName: fullName,
      role: role,
      onboarded: false,
      medicalConditions: [],
      allergies: [],
      routinePersona: "Senior Citizen",
      adherencePercentage: 100.0,
      createdAt: DateTime.now().toIso8601String(),
    );
    notifyListeners();
    return true;
  }

  Future<bool> loginWithGoogle() async {
    // Simulated Google OAuth login
    _isAuthenticated = true;
    _currentUserProfile = UserProfile(
      userId: "google-user-999",
      email: "google.patient@gmail.com",
      fullName: "Google Authenticated User",
      role: "User",
      onboarded: true,
      medicalConditions: ["Type 2 Diabetes"],
      allergies: [],
      routinePersona: "Senior Citizen",
      adherencePercentage: 98.0,
      createdAt: DateTime.now().toIso8601String(),
    );
    notifyListeners();
    return true;
  }

  Future<bool> requestPhoneOTP(String phoneNumber) async {
    // Simulated SMS OTP request
    return true;
  }

  Future<bool> verifyPhoneOTP(String phoneNumber, String otp) async {
    _isAuthenticated = true;
    _currentUserProfile = UserProfile(
      userId: "phone-user-888",
      email: "$phoneNumber@phone.dosebuddy.ai",
      fullName: "SMS Verified Patient",
      role: "User",
      onboarded: true,
      medicalConditions: [],
      allergies: [],
      routinePersona: "Senior Citizen",
      adherencePercentage: 100.0,
      createdAt: DateTime.now().toIso8601String(),
    );
    notifyListeners();
    return true;
  }

  Future<void> sendPasswordReset(String email) async {
    // Password reset request logic
  }

  void logout() {
    _isAuthenticated = false;
    _authToken = null;
    _currentUserProfile = null;
    notifyListeners();
  }
}
