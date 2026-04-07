import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/kankui_icons.dart';

/// Barra de navegación inferior personalizada con estética Kankuama
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.terracota.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: _buildIcon(0),
            label: 'Inicio',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: _buildIcon(1),
            label: 'Aprender',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _ScannerNavItem(
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: _buildIcon(3),
            label: 'Ranking',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavItem(
            icon: _buildIcon(4),
            label: 'Perfil',
            isSelected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(int index) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.terracota : AppColors.textoClaro;

    switch (index) {
      case 0:
        return KankuiIcons.sierra(size: 24, color: color);
      case 1:
        return KankuiIcons.mochila(size: 24, color: color);
      case 3:
        return KankuiIcons.circuloSabiduria(size: 24, color: color);
      case 4:
        return KankuiIcons.espiral(size: 24, color: color);
      default:
        return Icon(Icons.circle, size: 24, color: color);
    }
  }
}

class _NavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.terracota.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.terracota : AppColors.textoClaro,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón especial para el escáner (más grande y destacado)
class _ScannerNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _ScannerNavItem({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [AppColors.verdeSelva, AppColors.verdeMontana]
                : [AppColors.terracota, AppColors.terracotaLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isSelected ? AppColors.verdeSelva : AppColors.terracota)
                  .withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: KankuiIcons.ojoAncestral(size: 28, color: Colors.white),
        ),
      ),
    );
  }
}

