import 'package:flutter/material.dart';
import 'dart:ui'; // Nécessaire pour ImageFilter

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry?
  padding; // Changé en EdgeInsetsGeometry pour plus de flexibilité
  final EdgeInsetsGeometry? margin; // AJOUTÉ : Pour l'espacement externe
  final double? width; // AJOUTÉ : Pour la taille fixe
  final double? height; // AJOUTÉ : Pour la taille fixe
  final bool hasShadow;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.2,
    this.borderRadius,
    this.borderColor,
    this.padding,
    this.margin, // On le récupère ici
    this.width, // Ici
    this.height, // Et ici
    this.hasShadow = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Container extérieur pour gérer la taille (width/height) et les marges (margin)
    return Container(
      width: width,
      height: height,
      margin: margin,
      // 2. ClipRRect pour couper le flou qui dépasse
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          // 3. Container intérieur pour la couleur, l'opacité et la bordure
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(20),
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: hasShadow
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
