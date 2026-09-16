import 'package:flutter/material.dart';
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
    ),
    AboutSection(
      title: 'GRAVITAS',
      description: 'graVITas is the annual technological and design festival of VIT Vellore, aimed at nurturing technical proficiency and innovative thinking among students. It serves as a platform for aspiring engineers and technologists to showcase their talents, exchange ideas, and participate in a wide array of technical events, workshops, and competitions.',
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
                
                // Sponsors placeholder
                const Text(
                  'OUR SPONSORS',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSponsorsGrid(),

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
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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

  Widget _buildSponsorsGrid() {
    // Placeholder grid since exact sponsor data needs to be manually entered later
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Icon(
              Icons.business,
              color: AppColors.textMuted,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}
