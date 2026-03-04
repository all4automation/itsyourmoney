class UserInput {
  final int currentAge;
  final int targetAge;
  final double currentAssets;
  final double grossAnnualIncome;
  final double savingsRate; // decimal, e.g. 0.20 for 20%
  final double incomeGrowthRate; // decimal, e.g. 0.03 for 3%

  // Save More Tomorrow: additional savings rate added on each income increase
  final bool saveMoreTomorrow;
  final double smtBoostRate; // decimal, e.g. 0.03 = 3% extra per raise
  final double smtMaxRate;   // decimal, max savings rate cap e.g. 0.50

  const UserInput({
    required this.currentAge,
    required this.targetAge,
    required this.currentAssets,
    required this.grossAnnualIncome,
    required this.savingsRate,
    required this.incomeGrowthRate,
    this.saveMoreTomorrow = false,
    this.smtBoostRate = 0.03,
    this.smtMaxRate = 0.50,
  });

  int get horizonYears => targetAge - currentAge;

  double get initialAnnualSavings => grossAnnualIncome * savingsRate;

  UserInput copyWith({
    int? currentAge,
    int? targetAge,
    double? currentAssets,
    double? grossAnnualIncome,
    double? savingsRate,
    double? incomeGrowthRate,
    bool? saveMoreTomorrow,
    double? smtBoostRate,
    double? smtMaxRate,
  }) {
    return UserInput(
      currentAge: currentAge ?? this.currentAge,
      targetAge: targetAge ?? this.targetAge,
      currentAssets: currentAssets ?? this.currentAssets,
      grossAnnualIncome: grossAnnualIncome ?? this.grossAnnualIncome,
      savingsRate: savingsRate ?? this.savingsRate,
      incomeGrowthRate: incomeGrowthRate ?? this.incomeGrowthRate,
      saveMoreTomorrow: saveMoreTomorrow ?? this.saveMoreTomorrow,
      smtBoostRate: smtBoostRate ?? this.smtBoostRate,
      smtMaxRate: smtMaxRate ?? this.smtMaxRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInput &&
          currentAge == other.currentAge &&
          targetAge == other.targetAge &&
          currentAssets == other.currentAssets &&
          grossAnnualIncome == other.grossAnnualIncome &&
          savingsRate == other.savingsRate &&
          incomeGrowthRate == other.incomeGrowthRate &&
          saveMoreTomorrow == other.saveMoreTomorrow &&
          smtBoostRate == other.smtBoostRate &&
          smtMaxRate == other.smtMaxRate;

  @override
  int get hashCode => Object.hash(
        currentAge,
        targetAge,
        currentAssets,
        grossAnnualIncome,
        savingsRate,
        incomeGrowthRate,
        saveMoreTomorrow,
        smtBoostRate,
        smtMaxRate,
      );
}
