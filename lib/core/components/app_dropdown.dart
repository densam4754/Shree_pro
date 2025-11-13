import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? labelText;
  final String? hintText;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;

  const AppDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final fillColor = this.fillColor ?? 
        (isDark ? AppTheme.grey800 : AppTheme.white);
    final borderColor = this.borderColor ?? 
        (isDark ? AppTheme.grey600 : AppTheme.grey300);
    final borderRadius = this.borderRadius ?? 12.0;

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: fillColor,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: isDark ? AppTheme.grey400 : AppTheme.grey600,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: AppTheme.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppTheme.grey400 : AppTheme.grey600,
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppTheme.grey500 : AppTheme.grey500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: isDark ? AppTheme.white : AppTheme.black,
      ),
      dropdownColor: fillColor,
      icon: Icon(
        Icons.arrow_drop_down,
        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
      ),
    );
  }
}

