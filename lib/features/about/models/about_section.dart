/// Represents a section in the About screen (e.g. Robowars, RoboVITics, graVITas).
class AboutSection {
  final String title;
  final String description;

  /// Optional asset path to a logo (e.g. a sponsor's logo) shown with this section.
  final String? logoAsset;

  const AboutSection({
    required this.title,
    required this.description,
    this.logoAsset,
  });
}
