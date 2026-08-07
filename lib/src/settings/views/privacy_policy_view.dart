import 'package:eventee/core/widgets/view_appbar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://thethtookyaw.github.io/app-legal-document/eventee_privacy.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ViewAppbar(title: 'Privacy Policy', centerTitle: false),
      body: WebViewWidget(controller: _controller),
    );
  }
}
