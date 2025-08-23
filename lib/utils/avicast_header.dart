import 'package:flutter/material.dart';
import 'theme.dart';

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
                icon: Icon(
                  Icons.arrow_back,
                  color: AppTheme.textPrimaryColor,
                  size: 24,
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              ),
            if (showBackButton) const SizedBox(width: 10),
            
            // AVICAST Logo
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: AppTheme.avicastBlue,
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVICAST',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                    fontFamily: 'serif',
                  ),
                ),
                Text(
                  'FIELD TOOL',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
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
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ],
    );
  }
} 