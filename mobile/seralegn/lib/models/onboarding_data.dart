import 'user_role.dart';

class OnboardingData {
  UserRole role;
  String fullName;
  String phoneNumber;
  String neighborhood;
  String password;
  String faydaNumber;
  bool isFaydaVerified;
  Set<String> selectedCategories;

  OnboardingData({
    this.role = UserRole.client,
    this.fullName = '',
    this.phoneNumber = '',
    this.neighborhood = '',
    this.password = '',
    this.faydaNumber = '',
    this.isFaydaVerified = false,
    Set<String>? selectedCategories,
  }) : selectedCategories = selectedCategories ?? {};

  void resetForRole(UserRole newRole) {
    role = newRole;
    fullName = newRole.defaultNameExample;
    phoneNumber = newRole.defaultPhoneExample;
    neighborhood = newRole.defaultNeighborhoodExample;
    password = '';
    faydaNumber = '';
    isFaydaVerified = false;
    selectedCategories.clear();
  }
}
