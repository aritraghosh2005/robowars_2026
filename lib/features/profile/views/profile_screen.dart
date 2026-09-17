import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/core/auth/role_mode.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';
import 'package:robowars_app/features/teams/models/team.dart';
import 'package:robowars_app/services/service_providers.dart';
import 'package:robowars_app/shared/widgets/secondary_app_bar.dart';

// Resolves the participant's own team from the stream.
final _myTeamProvider = StreamProvider.autoDispose.family((ref, String teamId) {
  return ref
      .watch(teamDaoProvider)
      .watchTeams()
      .map((teams) => teams.where((t) => t.id == teamId).firstOrNull);
});

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _dropController;
  late final Animation<double> _dropAnim;
  late final Animation<double> _fadeAnim;
  late final AnimationController _teamDropController;
  late final Animation<double> _teamDropAnim;
  late final Animation<double> _teamFadeAnim;

  @override
  void initState() {
    super.initState();

    // User card: drops from top with a slight overshoot bounce.
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _dropAnim = CurvedAnimation(parent: _dropController, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _dropController, curve: Curves.easeIn);

    // Team card: drops slightly later for a staggered feel.
    _teamDropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _teamDropAnim = CurvedAnimation(parent: _teamDropController, curve: Curves.easeOutBack);
    _teamFadeAnim = CurvedAnimation(parent: _teamDropController, curve: Curves.easeIn);

    _dropController.forward();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _teamDropController.forward();
    });
  }

  @override
  void dispose() {
    _dropController.dispose();
    _teamDropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final user = ref.watch(currentUserProvider);

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const SecondaryAppBar(title: 'PROFILE'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
            child: Column(
              children: [
                // ── User ID card ──────────────────────────────
                _DropInCard(
                  dropAnim: _dropAnim,
                  fadeAnim: _fadeAnim,
                  child: _UserIdCard(user: user),
                ),

                const SizedBox(height: 20),

                // ── Team ID card (participant only) ───────────
                if (user != null &&
                    user.role == UserRole.participant &&
                    user.teamId != null)
                  _DropInCard(
                    dropAnim: _teamDropAnim,
                    fadeAnim: _teamFadeAnim,
                    child: _TeamIdCard(teamId: user.teamId!, ref: ref),
                  ),

                // ── Admin shortcut ────────────────────────────
                if (user != null && user.role == UserRole.admin)
                  _DropInCard(
                    dropAnim: _teamDropAnim,
                    fadeAnim: _teamFadeAnim,
                    child: _AdminShortcutCard(
                      onTap: () => context.push('/admin'),
                    ),
                  ),

                const SizedBox(height: 36),

                // ── Logout ────────────────────────────────────
                FadeTransition(
                  opacity: _teamFadeAnim,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).signOut();
                        ref
                            .read(activeRoleModeProvider.notifier)
                            .setRole(RoleMode.viewer);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _teamFadeAnim,
                  child: const Text(
                    'Made with ❤️ by RoboVITics',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Drop-in wrapper — slides from -120 offset to 0 + fades in.
// ─────────────────────────────────────────────────────────────
class _DropInCard extends StatelessWidget {
  final Animation<double> dropAnim;
  final Animation<double> fadeAnim;
  final Widget child;

  const _DropInCard({
    required this.dropAnim,
    required this.fadeAnim,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dropAnim,
      builder: (context, _) {
        final offset = (1.0 - dropAnim.value) * -140.0;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Opacity(
            opacity: fadeAnim.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// User ID Card
// ─────────────────────────────────────────────────────────────
class _UserIdCard extends StatelessWidget {
  final AppUser? user;
  const _UserIdCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final roleLabel = user?.role.name.toUpperCase() ?? 'GUEST';
    final roleColor = user?.role == UserRole.admin
        ? const Color(0xFFFFAA00)
        : user?.role == UserRole.participant
            ? AppColors.primary
            : AppColors.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle circuit-board pattern overlay
            Positioned.fill(child: _CircuitOverlay()),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: role badge + logo mark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: roleColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          roleLabel,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const Text(
                        'ROBOWARS',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Avatar + name + uid
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: roleColor, width: 2),
                        ),
                        child: user?.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(user!.avatarUrl!, fit: BoxFit.cover),
                              )
                            : Icon(Icons.person_outline, size: 32, color: roleColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Guest',
                              style: const TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.uid ?? '—',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                color: AppColors.textMuted,
                                letterSpacing: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),

                  // Contact fields
                  _IdField(
                    label: 'EMAIL',
                    value: user?.email ?? '—',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 10),
                  _IdField(
                    label: 'PHONE',
                    value: user?.phone ?? '—',
                    icon: Icons.phone_outlined,
                  ),
                  if (user?.teamId != null) ...[
                    const SizedBox(height: 10),
                    _IdField(
                      label: 'TEAM ID',
                      value: user!.teamId!,
                      icon: Icons.tag_outlined,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Barcode-like decorative strip
                  _BarcodeStrip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Team ID Card
// ─────────────────────────────────────────────────────────────
class _TeamIdCard extends ConsumerWidget {
  final String teamId;
  final WidgetRef ref;
  const _TeamIdCard({required this.teamId, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(_myTeamProvider(teamId));

    return teamAsync.when(
      loading: () => Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (team) {
        if (team == null) return const SizedBox.shrink();
        return _TeamCardContent(team: team);
      },
    );
  }
}

class _TeamCardContent extends StatelessWidget {
  final Team team;
  const _TeamCardContent({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(child: _CircuitOverlay()),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                        child: const Text(
                          'TEAM',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const Text(
                        '2026',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Team name + id
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.precision_manufacturing_outlined,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: const TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              team.id,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                color: AppColors.textMuted,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),

                  // Description
                  if (team.description.isNotEmpty) ...[
                    Text(
                      team.description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stats row
                  Row(
                    children: [
                      _StatChip(label: 'WINS', value: '${team.wins}', color: const Color(0xFF22C55E)),
                      const SizedBox(width: 10),
                      _StatChip(label: 'LOSSES', value: '${team.losses}', color: AppColors.primary),
                      const SizedBox(width: 10),
                      _StatChip(label: 'PTS', value: '${team.pts}', color: const Color(0xFFFFAA00)),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _BarcodeStrip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Admin shortcut card
// ─────────────────────────────────────────────────────────────
class _AdminShortcutCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AdminShortcutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFAA00).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFAA00).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.admin_panel_settings_outlined,
                color: Color(0xFFFFAA00), size: 22),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────
class _IdField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _IdField({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                color: AppColors.textMuted,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                color: AppColors.textMuted,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative barcode-style strip at the bottom of each card.
class _BarcodeStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(28, (i) {
        final isWide = i % 5 == 0 || i % 7 == 0;
        final opacity = (math.sin(i * 1.3) * 0.3 + 0.4).clamp(0.15, 0.55);
        return Expanded(
          flex: isWide ? 2 : 1,
          child: Container(
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 0.7),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }),
    );
  }
}

/// Subtle diagonal-line circuit overlay painted on the card.
class _CircuitOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CircuitPainter());
  }
}

class _CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.035)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal trace lines
    for (double y = 30; y < size.height; y += 50) {
      final path = Path()
        ..moveTo(0, y)
        ..lineTo(size.width * 0.3, y)
        ..lineTo(size.width * 0.3 + 12, y - 12)
        ..lineTo(size.width * 0.6, y - 12)
        ..lineTo(size.width * 0.6 + 8, y)
        ..lineTo(size.width, y);
      canvas.drawPath(path, paint);
    }

    // Corner dots
    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    for (final pos in [
      const Offset(20, 20),
      Offset(size.width - 20, 20),
      Offset(20, size.height - 20),
      Offset(size.width - 20, size.height - 20),
    ]) {
      canvas.drawCircle(pos, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
