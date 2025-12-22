import 'package:flutter/material.dart';
import '../models/class.dart';
import '../models/member.dart';
import '../models/duty.dart';
import '../models/task.dart';

class MockData {
  static const String currentUserName = 'Chim Cánh Cụt';
  static const String currentUserId = 'user_1';

  static final List<Member> classMembers = [
    Member(uid: 'm1', name: 'Nguyễn Văn An', classId: '1', role: MemberRole.thanhVien, joinedAt: DateTime.now(), updatedAt: DateTime.now()),
    Member(uid: 'm2', name: 'Trần Thị Bình', classId: '1', role: MemberRole.thanhVien, joinedAt: DateTime.now(), updatedAt: DateTime.now()),
    Member(uid: 'm3', name: 'Lê Văn Cường', classId: '1', role: MemberRole.thanhVien, joinedAt: DateTime.now(), updatedAt: DateTime.now()),
    Member(uid: 'm4', name: 'Phạm Thị Dung', classId: '1', role: MemberRole.canBoLop, joinedAt: DateTime.now(), updatedAt: DateTime.now()),
    Member(uid: 'm5', name: 'Hoàng Văn Em', classId: '1', role: MemberRole.thanhVien, joinedAt: DateTime.now(), updatedAt: DateTime.now()),
    Member(uid: 'm6', name: 'Vũ Thị Phương', classId: '1', role: MemberRole.thanhVien, joinedAt: DateTime.now(), updatedAt: DateTime.now()),
    Member(uid: 'm7', name: 'Đỗ Văn Giang', classId: '1', role: MemberRole.thanhVien, joinedAt: DateTime.now(), updatedAt: DateTime.now()),
    Member(uid: 'm8', name: 'Bùi Thị Hương', classId: '1', role: MemberRole.thanhVien, joinedAt: DateTime.now(), updatedAt: DateTime.now()),
  ];

  static final List<ClassMemberData> userClasses = [
    ClassMemberData(
      classData: Class(classId: '1', name: 'CS101·Product Ops', joinCode: 'PROD101', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      member: Member(
        uid: '1',
        name: currentUserName,
        classId: '1',
        role: MemberRole.quanLyLop,
        joinedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      borderColor: Colors.red,
    ),
    ClassMemberData(
      classData: Class(classId: '2', name: 'CS202·Advanced AI', joinCode: 'AI202', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      member: Member(
        uid: '2',
        name: currentUserName,
        classId: '2',
        role: MemberRole.canBoLop,
        joinedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      borderColor: Colors.blue,
    ),
    ClassMemberData(
      classData: Class(classId: '3', name: 'CS303·Data Science', joinCode: 'DATA303', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      member: Member(
        uid: '3',
        name: currentUserName,
        classId: '3',
        role: MemberRole.thanhVien,
        joinedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      borderColor: Colors.green,
    ),
    ClassMemberData(
      classData: Class(classId: '4', name: 'CS404·Mobile Development', joinCode: 'MOB404', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      member: Member(
        uid: '4',
        name: currentUserName,
        classId: '4',
        role: MemberRole.canBoLop,
        joinedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      borderColor: Colors.orange,
    ),
    ClassMemberData(
      classData: Class(classId: '5', name: 'CS505·Cloud Computing', joinCode: 'CLOUD505', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      member: Member(
        uid: '5',
        name: currentUserName,
        classId: '5',
        role: MemberRole.thanhVien,
        joinedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      borderColor: Colors.purple,
    ),
  ];

  static final List<Duty> duties = [
    Duty(
      id: 'd1',
      classId: '1',
      name: 'Clean Whiteboard',
      description: 'Clean the whiteboard after each class session.',
      startTime: DateTime.now().add(const Duration(hours: 2)),
      ruleName: 'Classroom Maintenance',
      points: 12,
      note: null,
      assigneeIds: ['user_1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Duty(
      id: 'd2',
      classId: '1',
      name: 'Arrange seating grid',
      description: 'Arrange desks and chairs according to the seating plan.',
      startTime: DateTime.now().add(const Duration(days: 1)),
      ruleName: 'Seating Arrangement',
      points: 15,
      note: null,
      assigneeIds: ['user_1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Duty(
      id: 'd3',
      classId: '1',
      name: 'Event: Văn nghệ 20/11',
      description: 'Prepare for cultural performance event.',
      startTime: DateTime.now().subtract(const Duration(days: 1)),
      ruleName: 'Events',
      points: 20,
      note: 'location:Hội trường T45',
      assigneeIds: ['user_1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Duty(
      id: 'd4',
      classId: '1',
      name: 'Collect class fund',
      description: 'Collect monthly class fund from all students.',
      startTime: DateTime.now().add(const Duration(days: 3)),
      ruleName: 'Funds',
      points: 10,
      note: 'amount:50000',
      assigneeIds: ['user_1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Duty(
      id: 'd5',
      classId: '1',
      name: 'Water plants',
      description: 'Water all plants in the classroom.',
      startTime: DateTime.now().add(const Duration(days: 4)),
      ruleName: 'Plant Care',
      points: 8,
      note: null,
      assigneeIds: ['user_1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Duty(
      id: 'd6',
      classId: '1',
      name: 'Event: AI Forum Setup',
      description: 'Help set up chairs and equipment for AI Forum.',
      startTime: DateTime.now().add(const Duration(days: 2)),
      ruleName: 'Events',
      points: 25,
      note: 'location:Phòng hội thảo F301',
      assigneeIds: ['user_1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Duty(
      id: 'd7',
      classId: '1',
      name: 'Reimburse printer costs',
      description: 'Process reimbursement for printing materials.',
      startTime: DateTime.now().add(const Duration(days: 5)),
      ruleName: 'Funds',
      points: 15,
      note: 'amount:120000',
      assigneeIds: ['user_1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static final List<Map<String, dynamic>> pendingApprovals = [
    {
      'memberName': 'Nguyen Van A',
      'memberAvatar': '',
      'dutyTitle': 'Clean Whiteboard',
      'submittedAt': '2 hours ago',
      'proofImageUrl': '',
    },
    {
      'memberName': 'Tran Thi B',
      'memberAvatar': '',
      'dutyTitle': 'Arrange seating grid',
      'submittedAt': '5 hours ago',
      'proofImageUrl': '',
    },
    {
      'memberName': 'Le Van C',
      'memberAvatar': '',
      'dutyTitle': 'Water plants',
      'submittedAt': 'Yesterday',
      'proofImageUrl': '',
    },
  ];

  static const List<String> ruleOptions = [
    'Classroom Maintenance',
    'Seating Arrangement',
    'Attendance',
    'Homework Collection',
    'Plant Care',
    'Equipment Management',
    'Events',
    'Funds',
    'General Duty',
  ];

  // Points associated with each rule
  static const Map<String, int> rulePoints = {
    'Classroom Maintenance': 12,
    'Seating Arrangement': 15,
    'Attendance': 20,
    'Homework Collection': 10,
    'Plant Care': 8,
    'Equipment Management': 15,
    'Events': 20,
    'Funds': 10,
    'General Duty': 10,
  };

  // Mock tasks assigned to the current member
  static final List<Task> memberTasks = [
    Task(
      id: 't1',
      dutyId: 'd1',
      classId: '1',
      uid: 'user_1',
      name: 'Clean Whiteboard',
      description: 'Clean the whiteboard after each class session.',
      status: TaskStatus.incomplete,
      startTime: DateTime.now().add(const Duration(hours: 2)),
      ruleName: 'Classroom Maintenance',
      points: 12,
      note: null,
      createdAt: DateTime.now(),
    ),
    Task(
      id: 't2',
      dutyId: 'd2',
      classId: '1',
      uid: 'user_1',
      name: 'Arrange seating grid',
      description: 'Arrange desks and chairs according to the seating plan.',
      status: TaskStatus.pending,
      startTime: DateTime.now().add(const Duration(days: 1)),
      ruleName: 'Seating Arrangement',
      points: 15,
      note: null,
      createdAt: DateTime.now(),
    ),
    Task(
      id: 't3',
      dutyId: 'd3',
      classId: '1',
      uid: 'user_1',
      name: 'Event: Văn nghệ 20/11',
      description: 'Prepare for cultural performance event.',
      status: TaskStatus.completed,
      startTime: DateTime.now().subtract(const Duration(days: 1)),
      ruleName: 'Events',
      points: 20,
      note: 'location:Hội trường T45',
      createdAt: DateTime.now(),
    ),
    Task(
      id: 't4',
      dutyId: 'd5',
      classId: '1',
      uid: 'user_1',
      name: 'Water plants',
      description: 'Water all plants in the classroom.',
      status: TaskStatus.incomplete,
      startTime: DateTime.now().add(const Duration(days: 4)),
      ruleName: 'Plant Care',
      points: 8,
      note: null,
      createdAt: DateTime.now(),
    ),
    Task(
      id: 't5',
      dutyId: 'd4',
      classId: '1',
      uid: 'user_1',
      name: 'Collect class fund',
      description: 'Collect monthly class fund from all students.',
      status: TaskStatus.incomplete,
      startTime: DateTime.now().add(const Duration(days: 3)),
      ruleName: 'Funds',
      points: 10,
      note: 'amount:50000',
      createdAt: DateTime.now(),
    ),
  ];

  static DutyExtraInfo? parseNoteField(String? note) {
    if (note == null || note.isEmpty) return null;
    
    if (note.startsWith('location:')) {
      return DutyExtraInfo(
        type: DutyExtraType.location,
        value: note.substring('location:'.length),
      );
    }
    else if (note.startsWith('amount:')) {
      final amount = int.tryParse(note.substring('amount:'.length)) ?? 0;
      return DutyExtraInfo(
        type: DutyExtraType.amount,
        value: _formatCurrency(amount),
      );
    }

    return null;
  }

  static String _formatCurrency(int amount) {
    return '₫${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}

class ClassMemberData {
  final Class classData;
  final Member member;
  final Color borderColor;

  ClassMemberData({
    required this.classData,
    required this.member,
    required this.borderColor,
  });
}

enum DutyExtraType {
  location,
  amount
}

class DutyExtraInfo {
  final DutyExtraType type;
  final String value;

  const DutyExtraInfo({required this.type, required this.value});

  IconData get icon => type == DutyExtraType.location  ? Icons.location_on_outlined : Icons.payments_outlined;
  String get label => type == DutyExtraType.location ? 'Địa điểm' : 'Số tiền';
}
