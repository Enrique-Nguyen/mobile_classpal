import 'package:flutter/material.dart';
import 'app_drawer.dart';

class DrawersButton extends StatelessWidget {
  final bool isDarkTheme;

  const DrawersButton({
    super.key,
    this.isDarkTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAppDrawer(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDarkTheme 
            ? Colors.white.withOpacity(0.1) 
            : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDarkTheme 
            ? null 
            : Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(
          Icons.grid_view_rounded,
          color: isDarkTheme ? Colors.white : Colors.black87,
          size: 20,
        ),
      ),
    );
  }
}
