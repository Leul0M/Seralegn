import 'package:get/get.dart';

enum AppLanguage { english, amharic }

class LanguageController extends GetxController {
  final _language = AppLanguage.english.obs;

  AppLanguage get language => _language.value;
  bool get isAmharic => _language.value == AppLanguage.amharic;

  void setLanguage(AppLanguage lang) => _language.value = lang;

  void toggleLanguage() {
    _language.value = _language.value == AppLanguage.english
        ? AppLanguage.amharic
        : AppLanguage.english;
  }

  String getText({required String en, required String am}) =>
      isAmharic ? am : en;

  // Tab labels
  String get homeTab => isAmharic ? 'መነሻ' : 'Home';
  String get bookingsTab => isAmharic ? 'ቀጠሮዎች' : 'Bookings';
  String get profileTab => isAmharic ? 'ፕሮፋይል' : 'Profile';
  String get feedTab => isAmharic ? 'የሥራ ዝርዝር' : 'Feed';
  String get myJobsTab => isAmharic ? 'የእኔ ሥራዎች' : 'My Jobs';

  // Action strings
  String get bookWorker => isAmharic ? 'ቀጠሮ ይያዙ' : 'Book a Worker';
  String get newBooking => isAmharic ? '+ አዲስ ቀጠሮ' : '+ New Booking';
  String get logout => isAmharic ? 'ሁነታውን ውጣ' : 'Log Out';
  String get confirmLogout =>
      isAmharic ? 'እርግጠኛ ነዎት መውጣት ይፈልጋሉ?' : 'Are you sure you want to log out?';
  String get cancel => isAmharic ? 'ሰርዝ' : 'Cancel';
  String get languageTitle => isAmharic ? 'ቋንቋ (Language)' : 'Language';
  String get selectTime => isAmharic ? 'ሰዓት ይምረጡ' : 'Select Time';
  String get useCurrentGps => isAmharic ? 'የአሁኑን ጂፒኤስ ተጠቀም' : 'Use Current GPS';
  String get shareLocation =>
      isAmharic ? 'ቦታ በካርታ አጋራ' : 'Share Location via Map';
}
