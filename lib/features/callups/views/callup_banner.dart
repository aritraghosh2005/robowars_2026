import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/features/callups/models/callup_item.dart';
import 'package:robowars_app/services/service_providers.dart';

class CallupBanner extends ConsumerStatefulWidget {
  const CallupBanner({super.key});

  @override
  ConsumerState<CallupBanner> createState() => _CallupBannerState();
}

class _CallupBannerState extends ConsumerState<CallupBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Set<String> _dismissedCallupIds = <String>{};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    // Only show for participants with a teamId
    if (user == null || user.teamId == null) {
      return const SizedBox.shrink();
    }

    final callupStream = ref.watch(callupDaoProvider).watchActiveCallupForTeam(user.teamId!);

    return StreamBuilder<CallupItem?>(
      stream: callupStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final callup = snapshot.data!;
        if (_dismissedCallupIds.contains(callup.id)) {
          return const SizedBox.shrink();
        }

        return FadeTransition(
          opacity: _animation,
          child: Container(
            width: double.infinity,
            color: const Color(0xFFFF2B55),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'URGENT CALL-UP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Space Grotesk',
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          callup.message,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _dismissedCallupIds.add(callup.id);
                      });
                    },
                    tooltip: 'Dismiss call-up',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
