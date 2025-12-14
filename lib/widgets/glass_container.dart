import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism (матовое стекло) контейнер с blur эффектом
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final List<Color>? gradientColors;
  final Gradient? gradient;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    this.child,
    this.borderRadius = 16,
    this.blur = 10,
    this.opacity = 0.1,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.border,
    this.boxShadow,
    this.gradientColors,
    this.gradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = color ?? 
        (isDark 
            ? Colors.white.withValues(alpha: opacity)
            : Colors.white.withValues(alpha: opacity + 0.1));
            
    // Если есть градиентные цвета, используем градиент
    final decoration = gradientColors != null 
      ? BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors!.map((c) => 
                c.withValues(alpha: isDark ? 0.8 : 0.9)).toList(),
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(
            color: borderColor ?? (isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.4)),
            width: 1.5,
          ),
        )
      : (gradient != null
          ? BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: borderColor ?? (isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.4)),
                width: 1.5,
              ),
            )
          : BoxDecoration(
              color: defaultColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: borderColor ?? (isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.4)),
                width: 1.5,
              ),
            ));

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: decoration,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Градиентный Glass контейнер с анимированными переливами
class GradientGlassContainer extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GradientGlassContainer({
    super.key,
    required this.child,
    required this.gradientColors,
    this.borderRadius = 16,
    this.blur = 10,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors.map((c) => 
                    c.withValues(alpha: isDark ? 0.3 : 0.4)).toList(),
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.4),
                width: 1.5,
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glass карточка с hover эффектом
class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 16,
    this.padding,
    this.margin,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: GlassContainer(
          borderRadius: widget.borderRadius,
          padding: widget.padding ?? const EdgeInsets.all(16),
          margin: widget.margin,
          blur: _isPressed ? 8 : 10,
          opacity: _isPressed ? 0.15 : 0.1,
          child: widget.child,
        ),
      ),
    );
  }
}
