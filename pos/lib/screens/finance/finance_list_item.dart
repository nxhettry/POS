import 'package:flutter/material.dart';

class FinanceListItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const FinanceListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<FinanceListItem> createState() => _FinanceListItemState();
}

class _FinanceListItemState extends State<FinanceListItem>
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
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: widget.isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.green[600]!,
                        Colors.green[700]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isSelected
                  ? null
                  : _isHovered
                      ? Colors.green.withOpacity(0.1)
                      : Colors.transparent,
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
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
                          color: Colors.green.withOpacity(0.3),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      // Icon with animated background
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.isSelected
                              ? Colors.white.withOpacity(0.2)
                              : _isHovered
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.isSelected
                              ? Colors.white
                              : _isHovered
                                  ? Colors.green[600]
                                  : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Title
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: widget.isSelected || _isHovered
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: widget.isSelected
                                ? Colors.white
                                : _isHovered
                                    ? Colors.green[600]
                                    : Colors.grey[800],
                          ),
                          child: Text(widget.title),
                        ),
                      ),
                      
                      // Selection indicator
                      if (widget.isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      else if (_isHovered)
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.green[600],
                          size: 16,
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
