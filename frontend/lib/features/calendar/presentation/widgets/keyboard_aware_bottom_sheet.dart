import 'package:flutter/material.dart';

/// Keeps bottom-sheet content visible and scrollable while the mobile keyboard
/// is open.
class KeyboardAwareBottomSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry contentPadding;
  final bool scrollContent;

  const KeyboardAwareBottomSheet({
    super.key,
    required this.child,
    this.contentPadding = const EdgeInsets.fromLTRB(16, 16, 16, 24),
    this.scrollContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final content = scrollContent
        ? SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: contentPadding,
            child: child,
          )
        : Padding(padding: contentPadding, child: child);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(top: false, child: content),
    );
  }
}
