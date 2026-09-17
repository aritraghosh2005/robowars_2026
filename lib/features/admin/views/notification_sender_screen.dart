import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/admin/viewmodels/notification_sender_viewmodel.dart';
import 'package:robowars_app/services/service_providers.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';

class NotificationSenderScreen extends ConsumerStatefulWidget {
  const NotificationSenderScreen({super.key});

  @override
  ConsumerState<NotificationSenderScreen> createState() => _NotificationSenderScreenState();
}

class _NotificationSenderScreenState extends ConsumerState<NotificationSenderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(notificationSenderViewModelProvider.notifier)
          .sendNotification(_titleController.text.trim(), _contentController.text.trim());

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Push notification broadcasted to all participants!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(notificationSenderViewModelProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleState = ref.watch(roleServiceProvider).asData?.value;
    if (roleState == null || roleState.service is! AdminService) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, iconTheme: const IconThemeData(color: Colors.white)),
        body: const Center(
          child: Text('Permission denied: Not an admin', style: TextStyle(color: Colors.red, fontSize: 18)),
        ),
      );
    }

    final state = ref.watch(notificationSenderViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'NOTIFICATION SENDER',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.podcasts_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GLOBAL PUSH BROADCAST',
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Instantly transmits a push notification to all checked-in arena participants.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title Label & Field
              const Text(
                'NOTIFICATION TITLE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontFamily: 'Space Grotesk'),
                decoration: InputDecoration(
                  hintText: 'e.g. Arena B Schedule Change',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),

              // Content Label & Field
              const Text(
                'MESSAGE BODY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white, fontFamily: 'Space Grotesk'),
                decoration: InputDecoration(
                  hintText: 'Type message details to send to participants...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Message is required' : null,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: state.isLoading ? null : _submit,
                  icon: state.isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  label: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'BROADCAST TO PARTICIPANTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 14,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
