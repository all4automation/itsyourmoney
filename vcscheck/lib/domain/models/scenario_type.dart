enum ScenarioType {
  conservative,
  moderate,
  aggressive;

  String get label {
    switch (this) {
      case ScenarioType.conservative:
        return 'Conservative';
      case ScenarioType.moderate:
        return 'Moderate';
      case ScenarioType.aggressive:
        return 'Aggressive';
    }
  }

  String get description {
    switch (this) {
      case ScenarioType.conservative:
        return 'Low-risk, stable growth';
      case ScenarioType.moderate:
        return 'Balanced risk and reward';
      case ScenarioType.aggressive:
        return 'Higher risk, higher potential';
    }
  }

  double get defaultReturnRate {
    switch (this) {
      case ScenarioType.conservative:
        return 0.04; // 4%
      case ScenarioType.moderate:
        return 0.055; // 5.5%
      case ScenarioType.aggressive:
        return 0.07; // 7%
    }
  }
}
