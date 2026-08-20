import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/progress_header.dart';

class CategorySelectionScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const CategorySelectionScreen({
    super.key,
    required this.onboardingData,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late Set<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.from(widget.onboardingData.selectedCategories);
    if (_selectedCategories.isEmpty) {
      // Default initial selections matching design
      if (widget.onboardingData.role == UserRole.client) {
        _selectedCategories.add('plumbing');
        _selectedCategories.add('repairs');
      } else {
        _selectedCategories.add('electrical');
        _selectedCategories.add('painting');
      }
    }
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedCategories.contains(id)) {
        _selectedCategories.remove(id);
      } else {
        _selectedCategories.add(id);
      }
    });
  }

  void _handleContinue() {
    widget.onboardingData.selectedCategories = _selectedCategories;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.onboardingData.role;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProgressHeader(
              currentStep: 2,
              totalSteps: 3,
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      role.step2Title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role.step2Subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grid of categories
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.25,
                      ),
                      itemCount: CategoryCard.allCategories.length,
                      itemBuilder: (context, index) {
                        final item = CategoryCard.allCategories[index];
                        final isSelected = _selectedCategories.contains(item.id);

                        return CategoryCard(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => _toggleCategory(item.id),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Primary Button
                    ElevatedButton(
                      onPressed: _handleContinue,
                      child: Text(role.step2ButtonLabel),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
