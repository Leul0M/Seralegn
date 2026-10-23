import 'user_role.dart';

class OnboardingData {
  UserRole role;
  String fullName;
  String phoneNumber;
  String neighborhood;
  String password;
  String faydaQrHash;
  bool isFaydaVerified;
  Set<String> selectedCategories;

  // Fayda autofill fields
  String firstName;
  String fatherName;
  String dateOfBirth;
  String gender; // 'Male', 'Female', or ''

  // Profile image: holds raw bytes from Fayda face or user-picked image
  List<int>? profileImageBytes;

  OnboardingData({
    this.role = UserRole.client,
    this.fullName = '',
    this.phoneNumber = '',
    this.neighborhood = '',
    this.password = '',
    this.faydaQrHash = '',
    this.isFaydaVerified = false,
    Set<String>? selectedCategories,
    this.firstName = '',
    this.fatherName = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.profileImageBytes,
  }) : selectedCategories = selectedCategories ?? {};

  void resetForRole(UserRole newRole) {
    role = newRole;
    fullName = '';
    phoneNumber = '';
    neighborhood = '';
    password = '';
    faydaQrHash = '';
    isFaydaVerified = false;
    firstName = '';
    fatherName = '';
    dateOfBirth = '';
    gender = '';
    profileImageBytes = null;
    selectedCategories.clear();
  }
}
