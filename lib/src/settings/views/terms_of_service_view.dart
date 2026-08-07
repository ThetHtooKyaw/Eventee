import 'package:eventee/core/widgets/view_appbar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsOfServiceView extends StatefulWidget {
  const TermsOfServiceView({super.key});

  @override
  State<TermsOfServiceView> createState() => _TermsOfServiceViewState();
}

class _TermsOfServiceViewState extends State<TermsOfServiceView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          'https://thethtookyaw.github.io/app-legal-document/eventee_terms.html',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ViewAppbar(title: 'Terms of Service', centerTitle: false),
      body: WebViewWidget(controller: _controller),
    );
  }
}
