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

  // Fayda autofill fields
  String firstName;
  String fatherName;
  String dateOfBirth;
  String gender; // 'Male', 'Female', or ''
  String lastFanDigits;

  // Profile image: holds raw bytes from Fayda face or user-picked image
  List<int>? profileImageBytes;

  OnboardingData({
    this.role = UserRole.client,
    this.fullName = '',
    this.phoneNumber = '',
    this.neighborhood = '',
    this.password = '',
    this.faydaNumber = '',
    this.isFaydaVerified = false,
    Set<String>? selectedCategories,
    this.firstName = '',
    this.fatherName = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.lastFanDigits = '',
    this.profileImageBytes,
  }) : selectedCategories = selectedCategories ?? {};

  void resetForRole(UserRole newRole) {
    role = newRole;
    fullName = '';
    phoneNumber = '';
    neighborhood = '';
    password = '';
    faydaNumber = '';
    isFaydaVerified = false;
    firstName = '';
    fatherName = '';
    dateOfBirth = '';
    gender = '';
    lastFanDigits = '';
    profileImageBytes = null;
    selectedCategories.clear();
  }
}

