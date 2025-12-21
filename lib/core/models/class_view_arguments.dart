import 'class.dart';
import 'member.dart';

class ClassViewArguments {
  final Class classData;
  final Member member;

  const ClassViewArguments({
    required this.classData,
    required this.member,
  });
  ClassViewArguments.init({required this.classData, required this.member});

  factory ClassViewArguments.fromMap(Map<String, dynamic> map) {
    return ClassViewArguments(
      classData: Class.fromMap(map['classData']),
      member: Member.fromMap(map['member']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classData': classData.toMap(),
      'member': member.toMap(),
    };
  }
}
