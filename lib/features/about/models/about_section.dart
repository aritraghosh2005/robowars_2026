/// Represents a section in the About screen (e.g. Robowars, RoboVITics, graVITas).
class AboutSection {
  final String title;
  final String description;

  /// Optional asset path to a logo (e.g. a sponsor's logo) shown with this section.
  final String? logoAsset;

  /// Optional URL opened when the logo is tapped (e.g. a sponsor's website).
  final String? logoUrl;

  const AboutSection({
    required this.title,
    required this.description,
    this.logoAsset,
    this.logoUrl,
  });
}
