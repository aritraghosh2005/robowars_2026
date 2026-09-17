import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/admin/viewmodels/update_composer_viewmodel.dart';
import 'package:robowars_app/features/updates/models/update_item.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';
import 'package:robowars_app/services/service_providers.dart';

class UpdateComposerScreen extends ConsumerStatefulWidget {
  const UpdateComposerScreen({super.key});

  @override
  ConsumerState<UpdateComposerScreen> createState() => _UpdateComposerScreenState();
}

class _UpdateComposerScreenState extends ConsumerState<UpdateComposerScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  UpdateTag _selectedTag = UpdateTag.update;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(updateComposerViewModelProvider.notifier).submitUpdate(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          tag: _selectedTag,
        );

    final state = ref.read(updateComposerViewModelProvider);
    if (!mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post update: ${state.error}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update published to event feed!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
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

    final state = ref.watch(updateComposerViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'COMPOSE UPDATE',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: const Icon(Icons.campaign_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIVE TOURNAMENT FEED',
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
                            'Posts appear in real-time on the event feed visible to all viewers and teams.',
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

              // Tag Selector
              const Text(
                'UPDATE CATEGORY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<UpdateTag>(
                    value: _selectedTag,
                    dropdownColor: AppColors.surfaceAlt,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    items: UpdateTag.values.map((tag) {
                      return DropdownMenuItem(
                        value: tag,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: tag.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              tag.label.toUpperCase(),
                              style: TextStyle(
                                color: tag.color,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Space Grotesk',
                                letterSpacing: 1.2,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTag = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title Field
              const Text(
                'UPDATE TITLE',
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
                  hintText: 'e.g. Match 14 Starting in Arena Alpha',
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
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),

              // Content Field
              const Text(
                'DETAILS & DESCRIPTION',
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
                style: const TextStyle(color: Colors.white, fontFamily: 'Space Grotesk'),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter complete announcement or result details...',
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
                validator: (val) => val == null || val.trim().isEmpty ? 'Content is required' : null,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: state.isLoading ? null : _submit,
                  icon: state.isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.publish_rounded, color: Colors.white, size: 20),
                  label: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'PUBLISH TO EVENT FEED',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
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
