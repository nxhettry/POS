import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class DrawerListItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<DrawerListItem> createState() => _DrawerListItemState();
}

class _DrawerListItemState extends State<DrawerListItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context, base: 12),
              vertical: ResponsiveUtils.getSpacing(context, base: 3),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: widget.isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.red.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isSelected
                  ? null
                  : _isHovered
                      ? Colors.red.withOpacity(0.1)
                      : Colors.transparent,
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : _isHovered
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
              border: widget.isSelected
                  ? null
                  : _isHovered
                      ? Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
            ),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getSpacing(context),
                    vertical: ResponsiveUtils.getSpacing(context),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(
                          ResponsiveUtils.getSpacing(context, base: 10),
                        ),
                        decoration: BoxDecoration(
                          color: widget.isSelected
                              ? Colors.white.withOpacity(0.2)
                              : _isHovered
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.isSelected
                              ? Colors.white
                              : _isHovered
                                  ? Colors.red
                                  : Colors.grey[600],
                          size: ResponsiveUtils.isSmallDesktop(context) ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getSpacing(context)),
                      
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 17),
                            fontWeight: widget.isSelected || _isHovered
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: widget.isSelected
                                ? Colors.white
                                : _isHovered
                                    ? Colors.red
                                    : Colors.grey[800],
                          ),
                          child: Text(widget.title),
                        ),
                      ),
                      
                      if (widget.isSelected)
                        Container(
                          padding: EdgeInsets.all(
                            ResponsiveUtils.getSpacing(context, base: 4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: ResponsiveUtils.isSmallDesktop(context) ? 14 : 16,
                          ),
                        )
                      else if (_isHovered)
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.red,
                          size: ResponsiveUtils.isSmallDesktop(context) ? 14 : 16,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
