import 'package:flutter/material.dart';
import '../models/class.dart';
import '../models/member.dart';
import '../models/duty.dart';
import '../models/task.dart';

class MockData {
  static const String currentUserName = 'Chim Cánh Cụt';
  static const String currentUserId = 'user_1';

  static final List<Member> classMembers = [
    Member(id: 'm1', name: 'Nguyễn Văn An', classId: '1', role: MemberRole.thanhVien),
    Member(id: 'm2', name: 'Trần Thị Bình', classId: '1', role: MemberRole.thanhVien),
    Member(id: 'm3', name: 'Lê Văn Cường', classId: '1', role: MemberRole.thanhVien),
    Member(id: 'm4', name: 'Phạm Thị Dung', classId: '1', role: MemberRole.canBoLop),
    Member(id: 'm5', name: 'Hoàng Văn Em', classId: '1', role: MemberRole.thanhVien),
    Member(id: 'm6', name: 'Vũ Thị Phương', classId: '1', role: MemberRole.thanhVien),
    Member(id: 'm7', name: 'Đỗ Văn Giang', classId: '1', role: MemberRole.thanhVien),
    Member(id: 'm8', name: 'Bùi Thị Hương', classId: '1', role: MemberRole.thanhVien),
  ];

  static final List<ClassMemberData> userClasses = [
    ClassMemberData(
      classData: Class(id: '1', name: 'CS101·Product Ops'),
      member: Member(
        id: '1',
        name: currentUserName,
        classId: '1',
        role: MemberRole.quanLyLop,
      ),
      borderColor: Colors.red,
    ),
    ClassMemberData(
      classData: Class(id: '2', name: 'CS202·Advanced AI'),
      member: Member(
        id: '2',
        name: currentUserName,
        classId: '2',
        role: MemberRole.canBoLop,
      ),
      borderColor: Colors.blue,
    ),
    ClassMemberData(
      classData: Class(id: '3', name: 'CS303·Data Science'),
      member: Member(
        id: '3',
        name: currentUserName,
        classId: '3',
        role: MemberRole.thanhVien,
      ),
      borderColor: Colors.green,
    ),
    ClassMemberData(
      classData: Class(id: '4', name: 'CS404·Mobile Development'),
      member: Member(
        id: '4',
        name: currentUserName,
        classId: '4',
        role: MemberRole.canBoLop,
      ),
      borderColor: Colors.orange,
    ),
    ClassMemberData(
      classData: Class(id: '5', name: 'CS505·Cloud Computing'),
      member: Member(
        id: '5',
        name: currentUserName,
        classId: '5',
        role: MemberRole.thanhVien,
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
      note: null, // Plain duty, no extra field
    ),
    Duty(
      id: 'd2',
      classId: '1',
      name: 'Arrange seating grid',
      description: 'Arrange desks and chairs according to the seating plan.',
      startTime: DateTime.now().add(const Duration(days: 1)),
      ruleName: 'Seating Arrangement',
      points: 15,
      note: null, // Plain duty
    ),
    Duty(
      id: 'd3',
      classId: '1',
      name: 'Event: Văn nghệ 20/11',
      description: 'Prepare for cultural performance event.',
      startTime: DateTime.now().subtract(const Duration(days: 1)),
      ruleName: 'Events',
      points: 20,
      note: 'location:Hội trường T45', // Event-related, has location
    ),
    Duty(
      id: 'd4',
      classId: '1',
      name: 'Collect class fund',
      description: 'Collect monthly class fund from all students.',
      startTime: DateTime.now().add(const Duration(days: 3)),
      ruleName: 'Funds',
      points: 10,
      note: 'amount:50000', // Fund-related, has amount
    ),
    Duty(
      id: 'd5',
      classId: '1',
      name: 'Water plants',
      description: 'Water all plants in the classroom.',
      startTime: DateTime.now().add(const Duration(days: 4)),
      ruleName: 'Plant Care',
      points: 8,
      note: null, // Plain duty
    ),
    Duty(
      id: 'd6',
      classId: '1',
      name: 'Event: AI Forum Setup',
      description: 'Help set up chairs and equipment for AI Forum.',
      startTime: DateTime.now().add(const Duration(days: 2)),
      ruleName: 'Events',
      points: 25,
      note: 'location:Phòng hội thảo F301', // Event-related
    ),
    Duty(
      id: 'd7',
      classId: '1',
      name: 'Reimburse printer costs',
      description: 'Process reimbursement for printing materials.',
      startTime: DateTime.now().add(const Duration(days: 5)),
      ruleName: 'Funds',
      points: 15,
      note: 'amount:120000', // Fund-related
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

  // Mock tasks assigned to the current member
  static final List<Task> memberTasks = [
    Task(
      id: 't1',
      name: 'Clean Whiteboard',
      description: 'Clean the whiteboard after each class session.',
      status: TaskStatus.incomplete,
      startTime: DateTime.now().add(const Duration(hours: 2)),
      ruleName: 'Classroom Maintenance',
      points: 12,
      note: null,
    ),
    Task(
      id: 't2',
      name: 'Arrange seating grid',
      description: 'Arrange desks and chairs according to the seating plan.',
      status: TaskStatus.pending,
      startTime: DateTime.now().add(const Duration(days: 1)),
      ruleName: 'Seating Arrangement',
      points: 15,
      note: null,
    ),
    Task(
      id: 't3',
      name: 'Event: Văn nghệ 20/11',
      description: 'Prepare for cultural performance event.',
      status: TaskStatus.completed,
      startTime: DateTime.now().subtract(const Duration(days: 1)),
      ruleName: 'Events',
      points: 20,
      note: 'location:Hội trường T45',
    ),
    Task(
      id: 't4',
      name: 'Water plants',
      description: 'Water all plants in the classroom.',
      status: TaskStatus.incomplete,
      startTime: DateTime.now().add(const Duration(days: 4)),
      ruleName: 'Plant Care',
      points: 8,
      note: null,
    ),
    Task(
      id: 't5',
      name: 'Collect class fund',
      description: 'Collect monthly class fund from all students.',
      status: TaskStatus.incomplete,
      startTime: DateTime.now().add(const Duration(days: 3)),
      ruleName: 'Funds',
      points: 10,
      note: 'amount:50000',
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

  const ClassMemberData({
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
