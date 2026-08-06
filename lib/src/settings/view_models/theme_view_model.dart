import 'package:eventee/core/utils/base_view_model.dart';

class ThemeViewModel extends BaseViewModel {
  // Dependencies
  ThemeViewModel();

  // Variables
  bool _isDarkModel = false;

  // Getters
  bool get isDarkMode => _isDarkModel;

  // Use Cases
  void toggleTheme(bool value) {
    _isDarkModel = value;
    notifyListeners();
  }
}
