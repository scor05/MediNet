import 'package:flutter/material.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const CalendarAppBar({
    super.key,
    required this.title,
    required this.onPreviousWeek,
    required this.onNextWeek,
    this.leading,
    this.automaticallyImplyLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPreviousWeek,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNextWeek,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
