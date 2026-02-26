import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/user_input.dart';

class PreferencesRepository {
  static const _keyCurrentAge = 'current_age';
  static const _keyTargetAge = 'target_age';
  static const _keyCurrentAssets = 'current_assets';
  static const _keyGrossIncome = 'gross_income';
  static const _keySavingsRate = 'savings_rate';
  static const _keyIncomeGrowthRate = 'income_growth_rate';

  Future<void> saveUserInput(UserInput input) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentAge, input.currentAge);
    await prefs.setInt(_keyTargetAge, input.targetAge);
    await prefs.setDouble(_keyCurrentAssets, input.currentAssets);
    await prefs.setDouble(_keyGrossIncome, input.grossAnnualIncome);
    await prefs.setDouble(_keySavingsRate, input.savingsRate);
    await prefs.setDouble(_keyIncomeGrowthRate, input.incomeGrowthRate);
  }

  Future<UserInput?> loadUserInput() async {
    final prefs = await SharedPreferences.getInstance();
    final currentAge = prefs.getInt(_keyCurrentAge);
    if (currentAge == null) return null;

    return UserInput(
      currentAge: currentAge,
      targetAge: prefs.getInt(_keyTargetAge) ?? 65,
      currentAssets: prefs.getDouble(_keyCurrentAssets) ?? 0,
      grossAnnualIncome: prefs.getDouble(_keyGrossIncome) ?? 0,
      savingsRate: prefs.getDouble(_keySavingsRate) ?? 0,
      incomeGrowthRate: prefs.getDouble(_keyIncomeGrowthRate) ?? 0,
    );
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
