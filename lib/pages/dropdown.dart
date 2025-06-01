import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../design_system/colors.dart';
import '../design_system/typography.dart';

class CustomSortButton extends StatefulWidget {
  final List<String> sortOptions;
  final String selected;
  final Function(String) onSelected;

  const CustomSortButton({
    super.key,
    required this.sortOptions,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<CustomSortButton> createState() => _CustomSortButtonState();
}

class _CustomSortButtonState extends State<CustomSortButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 80,
        height: 144,
        left: position.dx - 50,  // 오른쪽 정렬
        top: position.dy + renderBox.size.height + 8,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(-32, 34),
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF131927).withOpacity(0.08),
                        offset: const Offset(2, 8),
                        blurRadius: 8,
                        spreadRadius: -4,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.grey100,
                      width: 1),
                   ),
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                    physics: const NeverScrollableScrollPhysics(),
                    children: widget.sortOptions.map((option) {
                      return GestureDetector(
                        onTap: () {
                          widget.onSelected(option);
                          _toggleOverlay();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Text(
                            option,
                            style: AppTypography.c1.withColor(AppColors.grey700),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleOverlay,
        child: Container(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.selected,
                style: AppTypography.c1.withColor(AppColors.grey700),
              ),
              SvgPicture.asset(
                'assets/icons/functions/Caret_Down_SM.svg',
                width: 16,
                height: 16,
                color: AppColors.grey300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
