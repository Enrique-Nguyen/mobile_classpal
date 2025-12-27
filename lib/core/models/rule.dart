enum RuleType {
  duty, event, fund
}

extension RuleTypeToString on RuleType {
  String get storageKey {
    switch (this) {
      case RuleType.duty:
        return 'duty';
      case RuleType.event:
        return 'event';
      case RuleType.fund:
        return 'fund';
    }
  }

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
  final String classId;
  final DateTime createdAt;

  @override
  int get hashCode => id.hashCode;

  Rule({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
    required this.classId,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;

    return other is Rule && other.id == id;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.storageKey,
      'points': points,
      'classId': classId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Rule.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type']?.toString().toLowerCase().trim() ?? '';
    final type = switch (typeStr) {
      'duty'  || 'nhiệm vụ' => RuleType.duty,
      'event' || 'sự kiện' => RuleType.event,
      'fund'  || 'quỹ' => RuleType.fund,
      _ => RuleType.duty,
    };

    return Rule(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: type,
      points: (map['points'] ?? 0).toDouble(),
      classId: map['classId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}
