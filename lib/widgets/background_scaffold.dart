import 'package:flutter/material.dart';
import 'package:scribocracy_new/theme.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget child;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const BackgroundScaffold({
    super.key, 
    required this.child, 
    this.bottomNavigationBar,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lusterWhite, // CORRECTION ICI
      appBar: appBar,
      body: child,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      // extendBody permet au contenu de passer sous la barre du bas si elle est transparente
      extendBody: true, 
      resizeToAvoidBottomInset: false, // Pour éviter que le clavier ne casse le design
    );
  }
}