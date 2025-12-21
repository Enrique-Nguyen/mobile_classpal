import 'class.dart';
import 'member.dart';

class ClassViewArguments {
  final Class classData;
  final Member member;

  const ClassViewArguments({
    required this.classData,
    required this.member,
  });
}
