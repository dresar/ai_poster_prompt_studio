import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/neo_theme.dart';

class NeoPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final bool isLoading;
  final Widget? icon;

  const NeoPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = NeoTheme.accentPink,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<NeoPrimaryButton> createState() => _NeoPrimaryButtonState();
}

class _NeoPrimaryButtonState extends State<NeoPrimaryButton> with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03,
    )..addListener(() {
        setState(() {});
      });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
      });

    if (widget.onPressed != null && !widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeoPrimaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isDisabled = widget.onPressed == null || widget.isLoading;
    if (isDisabled) {
      _pulseController.stop();
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _tapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _tapController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _tapController.reverse();
    }
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final combinedScale = isDisabled ? 1.0 : (1.0 - _tapController.value) * _pulseAnimation.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: Transform.scale(
        scale: combinedScale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: NeoTheme.neoBoxDecoration(
            color: isDisabled ? Colors.grey[300]! : widget.backgroundColor,
            borderRadius: 24.0,
            hasShadow: !isDisabled,
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: NeoTheme.borderStrong,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.text.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: NeoTheme.textPrimary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class NeoSecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final bool isLoading;
  final Widget? icon;

  const NeoSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = NeoTheme.accentYellow,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<NeoSecondaryButton> createState() => _NeoSecondaryButtonState();
}

class _NeoSecondaryButtonState extends State<NeoSecondaryButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03,
    )..addListener(() {
        setState(() {
          _scale = 1.0 - _controller.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          height: 48,
          decoration: NeoTheme.neoBoxDecoration(
            color: isDisabled ? Colors.grey[300]! : widget.backgroundColor,
            borderRadius: 16.0,
            hasShadow: !isDisabled,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: NeoTheme.borderStrong,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        widget.text.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: NeoTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
