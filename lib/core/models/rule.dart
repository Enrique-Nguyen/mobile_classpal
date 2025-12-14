enum RuleType {
  duty, event, fund
}

extension RuleTypeToString on RuleType {
  String get displayName {
    switch (this) {
      case RuleType.duty:
        return "Nhiệm vụ";
      case RuleType.event:
        return "Sự kiện";
      case RuleType.fund:
        return "Quỹ";
    }
  }
}

class Rule {
  final String id;
  final String name;
  final RuleType type;
  final double points;
  final String? classId;

  Rule({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
    this.classId,
  });
}
