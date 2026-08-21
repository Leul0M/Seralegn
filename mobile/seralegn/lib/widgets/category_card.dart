import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryItem {
  final String id;
  final String title;
  final IconData icon;

  const CategoryItem({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class CategoryCard extends StatelessWidget {
  final CategoryItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  static const List<CategoryItem> allCategories = [
    CategoryItem(id: 'plumbing', title: 'Plumbing', icon: Icons.plumbing_rounded),
    CategoryItem(id: 'electrical', title: 'Electrical', icon: Icons.electrical_services_rounded),
    CategoryItem(id: 'repairs', title: 'Repairs', icon: Icons.handyman_rounded),
    CategoryItem(id: 'painting', title: 'Painting', icon: Icons.format_paint_rounded),
    CategoryItem(id: 'cleaning', title: 'Cleaning', icon: Icons.local_offer_rounded),
    CategoryItem(id: 'delivery', title: 'Delivery', icon: Icons.local_shipping_rounded),
    CategoryItem(id: 'moving', title: 'Moving', icon: Icons.move_to_inbox_rounded),
    CategoryItem(id: 'gardening', title: 'Gardening', icon: Icons.grass_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightTealBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.inputBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                    : AppTheme.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.darkText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
