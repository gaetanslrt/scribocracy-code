import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserTab {
  final String id;
  WebViewController controller;
  String title;
  String url;
  bool isLoading;
  
  // On pourrait ajouter une screenshotController ici plus tard pour les aperçus visuels
  
  BrowserTab({
    required this.id,
    required this.controller,
    this.title = "Nouvel onglet",
    this.url = "",
    this.isLoading = false,
  });
}