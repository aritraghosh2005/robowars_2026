import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/schedule/models/match.dart';
import 'package:robowars_app/features/prediction/viewmodels/prediction_viewmodel.dart';
import 'package:robowars_app/features/prediction/repositories/prediction_providers.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';

class ExpandedPrediction extends StatefulWidget {
  final Match match;
  final String selectedTeam;
  const ExpandedPrediction({super.key, required this.match, required this.selectedTeam});

  @override
  State<ExpandedPrediction> createState() => _ExpandedPredictionState();
}

class _ExpandedPredictionState extends State<ExpandedPrediction> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppColors.border, height: 1),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'YOUR PREDICTION',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedTeam,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final predictionState = ref.watch(predictionViewModelProvider);
              final predictions = ref.watch(userPredictionsProvider).asData?.value;
              final hasPrediction = predictions?.containsKey(widget.match.id) == true;
              final isOpen = widget.match.isPredictionOpen;
              
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: predictionState.isLoading || !isOpen
                      ? null
                      : () async {
                          final currentUser = ref.read(authStateProvider).asData?.value;
                          if (currentUser == null) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please login to make a prediction')),
                            );
                            context.push('/auth');
                            return;
                          }
                          try {
                            await ref
                                .read(predictionViewModelProvider.notifier)
                                .submitPrediction(
                                  widget.match,
                                  widget.selectedTeam,
                                );
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  hasPrediction
                                      ? 'Prediction updated.'
                                      : 'Prediction submitted.',
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            final message = error
                                .toString()
                                .replaceFirst('Bad state: ', '')
                                .replaceFirst('Exception: ', '');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: predictionState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isOpen
                              ? hasPrediction
                                  ? 'UPDATE PREDICTION'
                                  : 'CONFIRM PREDICTION'
                              : 'PREDICTIONS CLOSED',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
