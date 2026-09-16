import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/about/models/about_section.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<AboutSection> sections = [
    AboutSection(
      title: 'ROBOWARS',
      description: 'Get ready for an adrenaline-fueled experience at Robowars! A spectacular display of engineering prowess and fierce competition where brilliant minds showcase their custom-built robots in thrilling battles. Scheduled from 18 to 20 September 2026, Robowars is a platform where technology meets combat. As part of graVITas 2026, it promises to be one of the most exciting events.',
    ),
    AboutSection(
      title: 'ROBOVITICS',
      description: 'RoboVITics is the official robotics club of VIT Vellore, a community of passionate individuals dedicated to exploring the realms of robotics and automation. Our mission is to foster innovation, provide hands-on experience, and create a collaborative environment for robotics enthusiasts to thrive.',
      logoAsset: 'assets/images/robovitics logo.svg',
    ),
    AboutSection(
      title: 'GRAVITAS',
      description: 'graVITas is the annual technological and design festival of VIT Vellore, aimed at nurturing technical proficiency and innovative thinking among students. It serves as a platform for aspiring engineers and technologists to showcase their talents, exchange ideas, and participate in a wide array of technical events, workshops, and competitions.',
      logoAsset: 'assets/images/newgravlogo-Ctub3_Gb.svg',
    ),
    // NOTE: description is a placeholder — not sourced from the repo. Please verify/replace.
    AboutSection(
      title: 'OUR SPONSOR — ANALOG DEVICES',
      description: 'Analog Devices, Inc. (ADI) is a global leader in the design and manufacture of analog, mixed-signal, and digital signal processing technology, powering everything from industrial automation to robotics. As a proud sponsor of Robowars 2026, ADI champions the next generation of engineers building and battling the robots on this stage.',
      logoAsset: 'assets/images/analog_devices_logo.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ABOUT',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header image or logo could go here
                Center(
                  child: Image.asset('assets/images/app_logo.png', height: 80),
                ),
                const SizedBox(height: 32),

                // Sections
                ...sections.map((section) => _buildSection(section)),

                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 24),

                // Follow links
                const Text(
                  'FOLLOW',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFollowLinks(),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(AboutSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (section.logoAsset != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: SvgPicture.asset(
                  section.logoAsset!,
                  height: 44,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            section.description,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowLinks() {
    final links = <_FollowLink>[
      _FollowLink(
        icon: const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.white, size: 20),
        label: 'X',
        onTap: () => launchUrl(Uri.parse('https://x.com/RoboVITics_HQ')),
      ),
      _FollowLink(
        icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white, size: 20),
        label: 'Instagram',
        onTap: () => launchUrl(Uri.parse('https://www.instagram.com/robovitics/?hl=en')),
      ),
      _FollowLink(
        icon: const FaIcon(FontAwesomeIcons.linkedinIn, color: Colors.white, size: 20),
        label: 'LinkedIn',
        onTap: () => launchUrl(Uri.parse('https://www.linkedin.com/company/robovitics/posts/')),
      ),
      _FollowLink(
        icon: const Icon(Icons.language, color: Colors.white, size: 20),
        label: 'robovitics.in',
        onTap: () => launchUrl(Uri.parse('https://robovitics.in')),
      ),
      _FollowLink(
        icon: const FaIcon(FontAwesomeIcons.facebookF, color: Colors.white, size: 20),
        label: 'Facebook',
        onTap: () => launchUrl(Uri.parse('https://www.facebook.com/robovitics/')),
      ),
      _FollowLink(
        icon: const Icon(Icons.mail_outline, color: Colors.white, size: 20),
        label: 'Email',
        onTap: () => launchUrl(Uri(scheme: 'mailto', path: 'robovitics@vit.ac.in')),
      ),
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          for (var i = 0; i < links.length; i++) ...[
            InkWell(
              onTap: links[i].onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    SizedBox(width: 24, child: Center(child: links[i].icon)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        links[i].label,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                  ],
                ),
              ),
            ),
            if (i != links.length - 1)
              const Divider(color: AppColors.border, height: 1),
          ],
        ],
      ),
    );
  }
}

class _FollowLink {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _FollowLink({required this.icon, required this.label, required this.onTap});
}
