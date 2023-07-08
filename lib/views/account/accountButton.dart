import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';

class AccountButton extends StatelessWidget {
  const AccountButton({
    super.key,
    required this.title,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.isLoading = false,
  });

  final String title;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 40,
        child: Center(
          child: isLoading
              ? LoadingIndicator(
                  color: fg,
                )
              : Text(
                  title,
                  style: TextStyle(
                    color: fg,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
