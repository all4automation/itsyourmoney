class UserInput {
  final int currentAge;
  final int targetAge;
  final double currentAssets;
  final double grossAnnualIncome;
  final double savingsRate; // decimal, e.g. 0.20 for 20%
  final double incomeGrowthRate; // decimal, e.g. 0.03 for 3%

  const UserInput({
    required this.currentAge,
    required this.targetAge,
    required this.currentAssets,
    required this.grossAnnualIncome,
    required this.savingsRate,
    required this.incomeGrowthRate,
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
  }) {
    return UserInput(
      currentAge: currentAge ?? this.currentAge,
      targetAge: targetAge ?? this.targetAge,
      currentAssets: currentAssets ?? this.currentAssets,
      grossAnnualIncome: grossAnnualIncome ?? this.grossAnnualIncome,
      savingsRate: savingsRate ?? this.savingsRate,
      incomeGrowthRate: incomeGrowthRate ?? this.incomeGrowthRate,
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
          incomeGrowthRate == other.incomeGrowthRate;

  @override
  int get hashCode => Object.hash(
        currentAge,
        targetAge,
        currentAssets,
        grossAnnualIncome,
        savingsRate,
        incomeGrowthRate,
      );
}
