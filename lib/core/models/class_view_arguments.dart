import 'class.dart';
import 'member.dart';

class ClassViewArguments {
  final Class classData;
  final Member currentMember;

  const ClassViewArguments({
    required this.classData,
    required this.currentMember,
  });
}
