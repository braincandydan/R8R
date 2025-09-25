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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = Colors.grey[600]!;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isCenter ? 16.0 : 12.0,
            horizontal: 8.0,
          ),
          decoration: BoxDecoration(
            color: isActive && isCenter
                ? activeColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive && isCenter
                ? Border.all(color: activeColor.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isCenter ? 12.0 : 8.0),
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(isCenter ? 16 : 12),
                  border: isActive
                      ? null
                      : Border.all(
                          color: inactiveColor.withOpacity(0.3),
                          width: 1,
                        ),
                ),
                child: FaIcon(
                  icon,
                  size: isCenter ? 24.0 : 20.0,
                  color: isActive ? Colors.white : inactiveColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: isCenter ? 12.0 : 10.0,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
