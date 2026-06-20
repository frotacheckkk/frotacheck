import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double iconSize;
  final double spacing;
  final bool compact;

  const AppLogo({
    super.key,
    this.iconSize = 30,
    this.spacing = 12,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // tenta carregar imagem de logo em assets/images/logo_shield.png
    final logoAsset = 'assets/images/logo_shield.png';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize + 14,
          height: iconSize + 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            logoAsset,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.secondary,
              child: Icon(Icons.shield, size: iconSize, color: Colors.white),
            ),
          ),
        ),
        if (!compact) ...[
          SizedBox(width: spacing - 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'FROTA CHECK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Gestão de frota',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
