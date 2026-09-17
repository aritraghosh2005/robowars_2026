import 'package:flutter/material.dart';
import 'package:robowars_app/shared/widgets/bot_loading_animation.dart';

class TabLoadingWrapper extends StatefulWidget {
  final List<Widget> headerSlivers;
  final List<Widget> contentSlivers;
  final ScrollController? controller;

  const TabLoadingWrapper({
    super.key,
    required this.headerSlivers,
    required this.contentSlivers,
    this.controller,
  });

  @override
  State<TabLoadingWrapper> createState() => _TabLoadingWrapperState();
}

class _TabLoadingWrapperState extends State<TabLoadingWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller,
      slivers: [
        ...widget.headerSlivers,
        if (_isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: BotLoadingAnimation(size: 80),
            ),
          )
        else
          ...widget.contentSlivers,
      ],
    );
  }
}
