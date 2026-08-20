enum UserRole {
  client,
  worker,
}

extension UserRoleExtension on UserRole {
  String get title {
    switch (this) {
      case UserRole.client:
        return 'I need help';
      case UserRole.worker:
        return 'I want to work';
    }
  }

  String get badgeText {
    switch (this) {
      case UserRole.client:
        return 'CLIENT';
      case UserRole.worker:
        return 'WORKER';
    }
  }

  String get description {
    switch (this) {
      case UserRole.client:
        return 'Post tasks, get customized offers, and hire trusted pros.';
      case UserRole.worker:
        return 'Find jobs nearby, offer your services, and earn daily ETB.';
    }
  }

  String get accountTitle {
    switch (this) {
      case UserRole.client:
        return 'Create client account';
      case UserRole.worker:
        return 'Create a worker account';
    }
  }

  String get accountSubtitle {
    switch (this) {
      case UserRole.client:
        return 'Please enter your real name and contact details to match with local pros reliably.';
      case UserRole.worker:
        return 'Enter your real information. Seralegn requires Fayda to verify identity.';
    }
  }

  String get nameFieldLabel {
    switch (this) {
      case UserRole.client:
        return 'Full Name';
      case UserRole.worker:
        return 'Full Name (as on ID)';
    }
  }

  String get defaultNameExample {
    switch (this) {
      case UserRole.client:
        return 'Solomon Ayalew';
      case UserRole.worker:
        return 'Yared Girma';
    }
  }

  String get defaultPhoneExample {
    switch (this) {
      case UserRole.client:
        return '912 345 678';
      case UserRole.worker:
        return '944 567 890';
    }
  }

  String get neighborhoodLabel {
    switch (this) {
      case UserRole.client:
        return 'Your Neighborhood (Addis Ababa)';
      case UserRole.worker:
        return 'Preferred Job Area (Addis Ababa)';
    }
  }

  String get defaultNeighborhoodExample {
    switch (this) {
      case UserRole.client:
        return 'Bole Atlas';
      case UserRole.worker:
        return 'Megenagna';
    }
  }

  String get step1ButtonLabel {
    switch (this) {
      case UserRole.client:
        return 'Continue to Categories';
      case UserRole.worker:
        return 'Continue to Skills';
    }
  }

  String get step2Title {
    switch (this) {
      case UserRole.client:
        return 'What do you need help with?';
      case UserRole.worker:
        return 'What are your top skills?';
    }
  }

  String get step2Subtitle {
    switch (this) {
      case UserRole.client:
        return 'Select one or more categories that interest you. This shapes your personalized feed.';
      case UserRole.worker:
        return 'Choose categories you can work in confidently. Clients will match you based on these skills.';
    }
  }

  String get step2ButtonLabel {
    switch (this) {
      case UserRole.client:
        return 'Continue';
      case UserRole.worker:
        return 'Continue to Verification';
    }
  }

  String get completionTitle {
    switch (this) {
      case UserRole.client:
        return "You're all set!";
      case UserRole.worker:
        return 'Ready to earn!';
    }
  }

  String get completionSubtitle {
    switch (this) {
      case UserRole.client:
        return 'Your account is verified. You can now post your first task and receive offers from verified pros.';
      case UserRole.worker:
        return 'Welcome to Seralegn. Our partners in Addis Ababa are posting hundreds of local tasks every single day.';
    }
  }

  String get stat1Value {
    switch (this) {
      case UserRole.client:
        return '2,400+';
      case UserRole.worker:
        return '12k+ Jobs';
    }
  }

  String get stat1Label {
    switch (this) {
      case UserRole.client:
        return 'Verified Workers';
      case UserRole.worker:
        return 'Completed';
    }
  }

  String get stat2Value {
    switch (this) {
      case UserRole.client:
        return '4.9 / 5.0';
      case UserRole.worker:
        return '< 10 mins';
    }
  }

  String get stat2Label {
    switch (this) {
      case UserRole.client:
        return 'Average Rating';
      case UserRole.worker:
        return 'Avg Match Time';
    }
  }

  String get primaryCtaLabel {
    switch (this) {
      case UserRole.client:
        return 'Post Your First Task';
      case UserRole.worker:
        return 'Browse Nearby Tasks';
    }
  }

  String get secondaryCtaLabel {
    switch (this) {
      case UserRole.client:
        return 'Explore Tasks';
      case UserRole.worker:
        return 'Complete Your Profile';
    }
  }
}
