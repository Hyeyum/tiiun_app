import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'dart:ui';

class ToastHelper {
  static OverlayEntry? _overlayEntry;

  static void showTopToast({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    // 기존 토스트가 있다면 제거
    _removeToast();

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => TopToastWidget(
        message: message,
        backgroundColor: backgroundColor ?? Colors.black.withOpacity(0.5),
        textColor: textColor ?? Colors.white,
        duration: duration,
        onDismiss: _removeToast,
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  static void _removeToast() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class TopToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const TopToastWidget({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<TopToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    // 애니메이션 시작
    _animationController.forward();

    // 지정된 시간 후 자동 제거
    Future.delayed(widget.duration, () {
      _dismiss();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    if (!mounted) return; // Widget이 dispose되었으면 바로 종료
    if (_animationController.isCompleted) {
      await _animationController.reverse();
      if (mounted) { // 애니메이션 후에도 한번 더 체크
        widget.onDismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    final hasAppBar = paddingTop >= 30; // 대략적 기준
    final topPosition = paddingTop + (hasAppBar ? 24 : 56 + 16);

    return Positioned(
      top: topPosition,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  // horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.message,
                  style: AppTypography.b1.withColor(widget.textColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}