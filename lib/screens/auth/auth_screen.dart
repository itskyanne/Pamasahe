import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/notification_banner.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AuthScreen({super.key, this.onSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;
  final _emailController = TextEditingController(text: 'dwayne.paulino@gmail.com');
  final _passwordController = TextEditingController(text: 'student2026');
  final _nameController = TextEditingController(text: 'Dwayne Paulino');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth(AppState state) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      NotificationBanner.showError(context, 'Please enter a valid student email address.');
      return;
    }
    if (password.length < 6) {
      NotificationBanner.showError(context, 'Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);
    final supabase = SupabaseService();

    final result = _isSignUp
        ? await supabase.signUpWithEmail(email: email, password: password, fullName: _nameController.text.trim())
        : await supabase.signInWithEmail(email: email, password: password);

    setState(() => _isLoading = false);

    if (result.success && mounted) {
      state.setCloudUser(result.email ?? email, result.id ?? 'uuid-user');
      if (_nameController.text.trim().isNotEmpty) {
        state.setUserName(_nameController.text.trim());
      }
      NotificationBanner.showSuccess(
        context,
        _isSignUp ? 'Account created & linked to Supabase Cloud!' : 'Welcome back! Signed in to Supabase.',
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else if (mounted) {
      NotificationBanner.showError(context, result.error ?? 'Authentication failed');
    }
  }

  Future<void> _handleGoogleAuth(AppState state) async {
    setState(() => _isLoading = true);
    final supabase = SupabaseService();
    final result = await supabase.signInWithGoogle();
    setState(() => _isLoading = false);

    if (result.success && mounted) {
      state.setCloudUser(result.email ?? 'dwayne.paulino@gmail.com', result.id ?? 'google-user-01');
      NotificationBanner.showSuccess(
        context,
        'Successfully authenticated with Google!',
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else if (mounted) {
      NotificationBanner.showError(context, result.error ?? 'Google sign-in cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.deepGreen, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isSignUp ? 'Create Cloud Account' : 'Sign In to Pamasahe',
          style: const TextStyle(
            color: AppColors.deepGreen,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. BRAND HEADER
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.mainGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_sync_rounded, color: AppColors.mainGreen, size: 34),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Cloud Backup & Community Hub',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Connect with Supabase to back up your commute routes, share travel paths, and receive live fare updates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 2. GOOGLE SIGN-IN BUTTON
              OutlinedButton(
                onPressed: _isLoading ? null : () => _handleGoogleAuth(state),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1F2937),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.g_mobiledata_rounded, color: Color(0xFFEA4335), size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // OR DIVIDER
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR USE EMAIL',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                ],
              ),

              const SizedBox(height: 20),

              if (_isSignUp) ...[
                const Text(
                  'Full Name',
                  style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Dwayne Paulino',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              const Text(
                'Student / Commuter Email',
                style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'commuter@umindanao.edu.ph',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'Password',
                style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),

              const SizedBox(height: 24),

              // SUBMIT ACTION
              ElevatedButton(
                onPressed: _isLoading ? null : () => _handleEmailAuth(state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isSignUp ? 'Create Account & Connect' : 'Sign In with Email',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),

              const SizedBox(height: 16),

              // TOGGLE SIGN IN / SIGN UP
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp ? 'Already have an account? Sign In' : 'New commuter? Create an account',
                  style: const TextStyle(color: AppColors.mainGreen, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),

              const Divider(color: Color(0xFFE5E7EB)),
              const SizedBox(height: 8),

              // GUEST / OFFLINE MODE
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.offline_bolt_rounded, color: Color(0xFF6B7280), size: 18),
                label: const Text(
                  'Continue in Offline-First Mode (No Login Required)',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
