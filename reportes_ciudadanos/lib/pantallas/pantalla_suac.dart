import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PantallaSUAC extends StatefulWidget {
  final String url;

  const PantallaSUAC({super.key, required this.url});

  @override
  State<PantallaSUAC> createState() => _PantallaSUACState();
}

class _PantallaSUACState extends State<PantallaSUAC> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SUAC / Locatel',
          style:
              theme.textTheme.headlineSmall?.copyWith(color: Colors.white70),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}