import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Find tab (left)
              _buildNavItem(
                context,
                icon: FontAwesomeIcons.magnifyingGlass,
                label: 'Find',
                index: 0,
                isActive: currentIndex == 0,
                onTap: () => context.go('/locations'),
              ),
              
              // Rate Wings tab (center - larger)
              _buildNavItem(
                context,
                icon: FontAwesomeIcons.drumstickBite,
                label: 'Rate Wings',
                index: 1,
                isActive: currentIndex == 1,
                onTap: () => context.go('/rate'),
                isCenter: true,
              ),
              
              // Rewards tab (right)
              _buildNavItem(
                context,
                icon: FontAwesomeIcons.trophy,
                label: 'Rewards',
                index: 2,
                isActive: currentIndex == 2,
                onTap: () => context.go('/rewards'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
    bool isCenter = false,
  }) {
    final theme = Theme.of(context);
    final activeColor = const Color(0xFFFF6B35);
    final inactiveColor = Colors.grey[500]!;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: isCenter ? 16.0 : 12.0,
            horizontal: 8.0,
          ),
          decoration: BoxDecoration(
            color: isActive && isCenter
                ? activeColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isCenter ? 14.0 : 10.0),
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(isCenter ? 18 : 14),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: FaIcon(
                  icon,
                  size: isCenter ? 26.0 : 22.0,
                  color: isActive ? Colors.white : inactiveColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: isCenter ? 13.0 : 11.0,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
