import 'package:eventee/core/view_models/base_view_model.dart';

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
