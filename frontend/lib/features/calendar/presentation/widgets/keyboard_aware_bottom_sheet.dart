import 'package:flutter/material.dart';

/// Keeps bottom-sheet content visible and scrollable while the mobile keyboard
/// is open.
class KeyboardAwareBottomSheet extends StatelessWidget {
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry footerPadding;
  final bool scrollContent;

  const KeyboardAwareBottomSheet({
    super.key,
    required this.child,
    this.footer,
    this.contentPadding = const EdgeInsets.fromLTRB(16, 16, 16, 24),
    this.footerPadding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
    this.scrollContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final scrollableContent = scrollContent
        ? SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: contentPadding,
            child: child,
          )
        : Padding(padding: contentPadding, child: child);
    final content = footer == null
        ? scrollableContent
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: scrollableContent),
              Material(
                elevation: 8,
                shadowColor: Colors.black26,
                color: Theme.of(context).colorScheme.surface,
                child: Padding(padding: footerPadding, child: footer),
              ),
            ],
          );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(top: false, child: content),
    );
  }
}
