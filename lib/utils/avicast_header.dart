import 'package:flutter/material.dart';

class AvicastHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final String? pageTitle;
  final bool showPageTitle;

  const AvicastHeader({
    super.key,
    this.onBackPressed,
    this.showBackButton = true,
    this.pageTitle,
    this.showPageTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with AVICAST branding
        Row(
          children: [
            // Back button (if enabled)
            if (showBackButton)
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF2C3E50),
                  size: 24,
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              ),
            if (showBackButton) const SizedBox(width: 10),
            
            // AVICAST Logo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flutter_dash,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            
            // AVICAST Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AVICAST',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    fontFamily: 'serif',
                  ),
                ),
                const Text(
                  'FIELD TOOL',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
        
        // Page title (if provided)
        if (showPageTitle && pageTitle != null) ...[
          const SizedBox(height: 20),
          Text(
            pageTitle!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ],
    );
  }
} 