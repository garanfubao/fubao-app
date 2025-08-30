import 'package:flutter/material.dart';
import '../utils/index.dart';

enum AppButtonType { primary, secondary, outline, text }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? customColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Size configurations
    final double height;
    final double fontSize;
    final EdgeInsets padding;
    
    switch (size) {
      case AppButtonSize.small:
        height = 32.0;
        fontSize = 12.0;
        padding = const EdgeInsets.symmetric(horizontal: AppTheme.spacingM);
        break;
      case AppButtonSize.medium:
        height = 40.0;
        fontSize = 14.0;
        padding = const EdgeInsets.symmetric(horizontal: AppTheme.spacingL);
        break;
      case AppButtonSize.large:
        height = 48.0;
        fontSize = 16.0;
        padding = const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL);
        break;
    }

    // Color configurations
    final Color backgroundColor;
    final Color foregroundColor;
    final Color? borderColor;

    switch (type) {
      case AppButtonType.primary:
        backgroundColor = customColor ?? AppTheme.primaryColor;
        foregroundColor = Colors.white;
        borderColor = null;
        break;
      case AppButtonType.secondary:
        backgroundColor = customColor ?? AppTheme.backgroundColor;
        foregroundColor = AppTheme.textPrimaryColor;
        borderColor = AppTheme.textDisabledColor;
        break;
      case AppButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = customColor ?? AppTheme.primaryColor;
        borderColor = customColor ?? AppTheme.primaryColor;
        break;
      case AppButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = customColor ?? AppTheme.primaryColor;
        borderColor = null;
        break;
    }

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: fontSize,
            height: fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
        ] else if (icon != null) ...[
          Icon(icon, size: fontSize + 2),
          const SizedBox(width: AppTheme.spacingS),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
      ],
    );

    if (isFullWidth) {
      buttonChild = SizedBox(
        width: double.infinity,
        child: Center(child: buttonChild),
      );
    }

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: type == AppButtonType.primary ? AppTheme.elevation2 : 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
          disabledBackgroundColor: AppTheme.textDisabledColor,
          disabledForegroundColor: Colors.white,
        ),
        child: buttonChild,
      ),
    );
  }
}
