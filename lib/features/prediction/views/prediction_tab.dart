import 'package:flutter/material.dart';
import 'package:robowars_app/features/prediction/views/expanded_prediction.dart';
import 'package:robowars_app/features/prediction/views/widgets/team_choice_widget.dart';
import 'package:robowars_app/features/prediction/views/widgets/vs_indicator.dart';

class PredictionTab extends StatefulWidget {
  final ValueChanged<bool> onExpandChanged;
  final VoidCallback onTabClicked;

  const PredictionTab({
    super.key,
    required this.onExpandChanged,
    required this.onTabClicked,
  });

  @override
  State<PredictionTab> createState() => _PredictionTabState();
}

class _PredictionTabState extends State<PredictionTab> {
  bool _isExpanded = false;
  Widget? _selectedChoice;
  bool _needsCollapse = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isExpanded) {
        _toggleExpansion(null);
      }
    });
  }

  void _toggleExpansion(Widget? choice) {
    if (!mounted) return;

    setState(() {
      if (choice != null) {
        _selectedChoice = choice;
        _needsCollapse = false;
      }
      _isExpanded = choice != null ? true : !_isExpanded;
    });

    widget.onExpandChanged(_isExpanded);
    if (choice != null) widget.onTabClicked();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsCollapse && _isExpanded) {
      _needsCollapse = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _toggleExpansion(null);
      });
    }

    return GestureDetector(
      onTap: () {
        widget.onTabClicked();
        if (_isExpanded) _toggleExpansion(null);
      },
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _toggleExpansion(
                    TeamChoiceWidget(teamName: 'Team A', isExpanded: _isExpanded),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: TeamChoiceWidget(
                    teamName: 'Team A',
                    isExpanded: _isExpanded,
                  ),
                ),
                const VSIndicator(),
                ElevatedButton(
                  onPressed: () => _toggleExpansion(
                    TeamChoiceWidget(teamName: 'Team B', isExpanded: _isExpanded),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: TeamChoiceWidget(
                    teamName: 'Team B',
                    isExpanded: _isExpanded,
                  ),
                ),
              ],
            ),
            if (_isExpanded && _selectedChoice != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ExpandedPrediction(choice: _selectedChoice!),
              ),
          ],
        ),
      ),
    );
  }
}
