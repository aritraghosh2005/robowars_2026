import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:robowars_app/features/auth/viewmodels/otp_viewmodel.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'AUTHENTICATION',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'VIEWER'),
            Tab(text: 'PARTICIPANT'),
            Tab(text: 'ADMIN'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ViewerAuthTab(),
          _ParticipantAuthTab(),
          _AdminAuthTab(),
        ],
      ),
    );
  }
}

class _ViewerAuthTab extends ConsumerWidget {
  const _ViewerAuthTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.public, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            'Join as a Viewer',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sign in to predict match winners and climb the prediction leaderboard.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () => ref.read(authViewModelProvider.notifier).signInWithGoogle(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 54),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.black)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.g_mobiledata, size: 32),
                      SizedBox(width: 8),
                      Text('Continue with Google'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantAuthTab extends ConsumerStatefulWidget {
  const _ParticipantAuthTab();

  @override
  ConsumerState<_ParticipantAuthTab> createState() => _ParticipantAuthTabState();
}

class _ParticipantAuthTabState extends ConsumerState<_ParticipantAuthTab> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpViewModelProvider);
    
    // Check if error
    if (otpState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(otpState.error!), backgroundColor: Colors.red),
        );
        ref.read(otpViewModelProvider.notifier).reset(); // Clear error after showing
      });
    }

    if (otpState.status == OtpStateEnum.codeSent || otpState.status == OtpStateEnum.verifying) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '123456',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: otpState.status == OtpStateEnum.verifying
                  ? null
                  : () {
                      ref.read(otpViewModelProvider.notifier).verifyOtp(_otpController.text);
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              child: otpState.status == OtpStateEnum.verifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify OTP'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.engineering, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            'Participant Login',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter your registered phone number.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: '+91 9876543210',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              prefixIcon: Icon(Icons.phone, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: otpState.status == OtpStateEnum.sending
                ? null
                : () {
                    // Ensure format begins with +
                    String phone = _phoneController.text.trim();
                    if (!phone.startsWith('+')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please include country code e.g. +91'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    ref.read(otpViewModelProvider.notifier).sendOtp(phone);
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
            ),
            child: otpState.status == OtpStateEnum.sending
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Send OTP'),
          ),
        ],
      ),
    );
  }
}

class _AdminAuthTab extends ConsumerStatefulWidget {
  const _AdminAuthTab();

  @override
  ConsumerState<_AdminAuthTab> createState() => _AdminAuthTabState();
}

class _AdminAuthTabState extends ConsumerState<_AdminAuthTab> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    // Show error snackbar if login fails
    ref.listen<AsyncValue<void>>(authViewModelProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.admin_panel_settings, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            'Admin Portal',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    ref.read(authViewModelProvider.notifier).signInWithAdmin(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Login'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    final email = _emailController.text.trim();
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter your admin email first.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    final error = await ref
                        .read(authViewModelProvider.notifier)
                        .resetAdminPassword(email);
                    if (!context.mounted) return;
                    if (error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Reset email sent! Check your inbox and set a new password.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: Colors.red.shade700,
                        ),
                      );
                    }
                  },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
