import 'package:app_links/app_links.dart';

class AppLinksService {
  static final _instance = AppLinksService._internal();
  final _appLinks = AppLinks();
  AppLinksService._internal();

  static AppLinksService get instance => _instance;
  Stream<Uri> get uriLinkStream => _appLinks.uriLinkStream;
}
