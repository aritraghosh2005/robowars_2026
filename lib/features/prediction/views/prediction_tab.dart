import 'package:flutter/material.dart';
import 'package:robowars_app/features/prediction/views/expanded_prediction.dart';
import 'package:robowars_app/features/prediction/views/widgets/team_choice_widget.dart';
import 'package:robowars_app/features/prediction/views/widgets/vs_indicator.dart';

import 'package:robowars_app/features/schedule/models/match.dart';

class PredictionTab extends StatefulWidget {
  final Match match;
  final ValueChanged<bool> onExpandChanged;
  final VoidCallback onTabClicked;

  const PredictionTab({
    super.key,
    required this.match,
    required this.onExpandChanged,
    required this.onTabClicked,
  });

  @override
  State<PredictionTab> createState() => _PredictionTabState();
}

class _PredictionTabState extends State<PredictionTab> {
  bool _isExpanded = false;
  String? _selectedTeam;
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

  void _toggleExpansion(String? team) {
    if (!mounted) return;

    setState(() {
      if (team != null) {
        _selectedTeam = team;
        _needsCollapse = false;
      }
      _isExpanded = team != null ? true : !_isExpanded;
    });

    widget.onExpandChanged(_isExpanded);
    if (team != null) widget.onTabClicked();
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
                  onPressed: () => _toggleExpansion(widget.match.team1),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: TeamChoiceWidget(
                    teamName: widget.match.team1,
                    isExpanded: _isExpanded,
                  ),
                ),
                const VSIndicator(),
                ElevatedButton(
                  onPressed: () => _toggleExpansion(widget.match.team2),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: TeamChoiceWidget(
                    teamName: widget.match.team2,
                    isExpanded: _isExpanded,
                  ),
                ),
              ],
            ),
            if (_isExpanded && _selectedTeam != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ExpandedPrediction(
                  match: widget.match,
                  selectedTeam: _selectedTeam!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
