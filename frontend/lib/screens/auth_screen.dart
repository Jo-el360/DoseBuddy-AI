import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailLoginCtrl = TextEditingController(text: 'patient@example.com');
  final _passwordLoginCtrl = TextEditingController(text: 'Password123!');

  final _fullNameRegCtrl = TextEditingController(text: 'Arthur Pendelton');
  final _emailRegCtrl = TextEditingController(text: 'new.patient@example.com');
  final _passwordRegCtrl = TextEditingController(text: 'SecurePass123!');
  
  String _selectedRole = 'User';
  final List<String> _roles = ['User', 'Caregiver', 'Doctor', 'Admin'];
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleEmailLogin() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.loginWithEmail(_emailLoginCtrl.text, _passwordLoginCtrl.text);
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  void _handleRegister() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.registerUser(
      email: _emailRegCtrl.text,
      password: _passwordRegCtrl.text,
      fullName: _fullNameRegCtrl.text,
      role: _selectedRole,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  void _handleGoogleLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.loginWithGoogle();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  void _showPhoneOTPDialog() {
    final phoneCtrl = TextEditingController(text: '+15550192834');
    final otpCtrl = TextEditingController(text: '123456');
    bool otpSent = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(otpSent ? 'Enter OTP Code' : 'Phone OTP Authentication', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!otpSent) ...[
                const Text('Enter mobile number to receive instant SMS verification code.'),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                ),
              ] else ...[
                const Text('Code sent to your mobile phone. Enter 6-digit code:'),
                const SizedBox(height: 12),
                TextField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '6-Digit OTP', prefixIcon: Icon(Icons.lock_clock), border: OutlineInputBorder()),
                ),
              ]
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final auth = Provider.of<AuthService>(context, listen: false);
                if (!otpSent) {
                  await auth.requestPhoneOTP(phoneCtrl.text);
                  setDialogState(() => otpSent = true);
                } else {
                  await auth.verifyPhoneOTP(phoneCtrl.text, otpCtrl.text);
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                }
              },
              child: Text(otpSent ? 'Verify & Sign In' : 'Send Code'),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text('Password reset instructions will be sent to your registered email.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent!')));
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoseBuddyTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.medical_services_rounded, size: 76, color: DoseBuddyTheme.primaryTeal),
                const SizedBox(height: 12),
                const Text('DoseBuddy AI', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: DoseBuddyTheme.primaryTeal)),
                const Text('Smart Medication & Health Companion', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(color: DoseBuddyTheme.primaryTeal, borderRadius: BorderRadius.circular(16)),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    tabs: const [Tab(text: 'SIGN IN'), Tab(text: 'REGISTER')],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 380,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // SIGN IN TAB
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _emailLoginCtrl,
                            style: const TextStyle(fontSize: 18),
                            decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordLoginCtrl,
                            obscureText: true,
                            style: const TextStyle(fontSize: 18),
                            decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v!)),
                                  const Text('Remember Me'),
                                ],
                              ),
                              TextButton(onPressed: _showForgotPasswordDialog, child: const Text('Forgot Password?')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleEmailLogin,
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(55)),
                            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SIGN IN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      // REGISTER TAB
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _fullNameRegCtrl,
                              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _emailRegCtrl,
                              decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passwordRegCtrl,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge), border: OutlineInputBorder()),
                              items: _roles.map((r) => DropdownMenuItem(value: r, child: Text('Role: $r'))).toList(),
                              onChanged: (val) => setState(() => _selectedRole = val!),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(55)),
                              child: const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR LOG IN WITH', style: TextStyle(fontSize: 12, color: Colors.grey))),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _handleGoogleLogin,
                        icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                        label: const Text('Google'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showPhoneOTPDialog,
                        icon: const Icon(Icons.sms, color: DoseBuddyTheme.primaryTeal),
                        label: const Text('Phone OTP'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
