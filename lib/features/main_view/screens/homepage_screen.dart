import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_classpal/core/constants/app_colors.dart';
import 'package:mobile_classpal/core/models/class_model.dart';
import 'package:mobile_classpal/core/models/member_model.dart';
import 'package:mobile_classpal/features/main_view/screens/create_class_screen.dart';
import 'package:mobile_classpal/features/main_view/screens/join_class_screen.dart';

// Class phụ để gom dữ liệu lại cho UI dễ hiển thị
class UserClassData {
  final ClassModel classModel;
  final MemberModel member;
  final Color borderColor;

  UserClassData({
    required this.classModel,
    required this.member,
    required this.borderColor,
  });
}

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Stream<DocumentSnapshot> _userStream;
  late Stream<List<UserClassData>> _classesStream;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  void _initStreams() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // 1. Stream lấy tên User hiển thị lời chào
    _userStream = _firestore.collection('users').doc(uid).snapshots();

    // 2. Stream lấy danh sách lớp
    // Tìm tất cả document trong collection 'members' có uid trùng với user hiện tại
    _classesStream = _firestore
        .collectionGroup('members')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .asyncMap((snapshot) async {
          List<UserClassData> loadedData = [];

          // Dùng Future.wait để tải song song thông tin chi tiết của các lớp
          await Future.wait(
            snapshot.docs.map((memberDoc) async {
              try {
                // A. Parse Member từ Firestore bằng hàm toObject
                MemberModel member = MemberModel.toObject(memberDoc.data());

                // B. Lấy reference đến document Class cha (nằm trên members 2 cấp)
                // Cấu trúc: classes/{classId}/members/{uid} -> parent là members -> parent.parent là classes/{classId}
                DocumentReference classRef = memberDoc.reference.parent.parent!;

                DocumentSnapshot classSnap = await classRef.get();

                if (classSnap.exists) {
                  // C. Parse ClassModel từ Firestore bằng hàm toObject bạn cung cấp
                  ClassModel classModel = ClassModel.toObject(
                    classSnap.data() as Map<String, dynamic>,
                  );

                  // D. Tạo màu ngẫu nhiên dựa trên ID lớp
                  Color randomColor = _generateColorFromId(classModel.classId);

                  loadedData.add(
                    UserClassData(
                      classModel: classModel,
                      member: member,
                      borderColor: randomColor,
                    ),
                  );
                }
              } catch (e) {
                print("Lỗi parse data lớp: $e");
              }
            }),
          );

          // Sắp xếp lớp mới tạo lên đầu
          loadedData.sort(
            (a, b) => b.classModel.createdAt.compareTo(a.classModel.createdAt),
          );

          return loadedData;
        });
  }

  // Hàm sinh màu cố định theo ID (để reload không bị đổi màu lung tung)
  Color _generateColorFromId(String id) {
    final int hash = id.hashCode;
    final Random random = Random(hash);
    return Color.fromARGB(
      255,
      random.nextInt(100) + 100, // Màu pastel tươi sáng
      random.nextInt(100) + 100,
      random.nextInt(100) + 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Vui lòng đăng nhập lại")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buildCreateJoinBotton(context),
        backgroundColor: AppColors.bannerBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: LỜI CHÀO ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: _userStream,
                    builder: (context, snapshot) {
                      String displayName = "Bạn";
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        displayName =
                            data['userName'] ??
                            _auth.currentUser?.email ??
                            "Bạn";
                      }
                      return _buildHelloWelcomeClass(displayName);
                    },
                  ),
                  _buildLogoutButton(context),
                ],
              ),
            ),

            // --- DANH SÁCH LỚP HỌC ---
            Expanded(
              child: StreamBuilder<List<UserClassData>>(
                stream: _classesStream,
                builder: (context, snapshot) {
                  // 1. Trạng thái đang tải
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. Trạng thái lỗi
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("Lỗi tải dữ liệu: ${snapshot.error}"),
                      ),
                    );
                  }

                  final classes = snapshot.data ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề section + Số lượng lớp
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Lớp của bạn (${classes.length})",
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textGrey, // Đã map theo AppColors
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ListView hiển thị thẻ lớp
                      Expanded(
                        child: classes.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: classes.length,
                                itemBuilder: (context, index) {
                                  final data = classes[index];
                                  return _buildClassCard(
                                    context: context,
                                    borderColor: data.borderColor,
                                    title: data.classModel.name,
                                    // Logic hiển thị vai trò
                                    subtitle: 'Vai trò: ${data.member.role}',
                                    classModel: data.classModel,
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.class_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Bạn chưa tham gia lớp nào",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  RichText _buildHelloWelcomeClass(String userName) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Chào mừng trở lại\n',
            style: TextStyle(fontSize: 15, color: AppColors.textGrey),
          ),
          TextSpan(
            text: userName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.logout_outlined, color: Colors.red, size: 20),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Widget _buildClassCard({
    required BuildContext context,
    required Color borderColor,
    required String title,
    required String subtitle,
    required ClassModel classModel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () {
          // Navigator.pushNamed(context, '/class_detail', arguments: classModel);
        },
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: borderColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E2D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.person, color: borderColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _buildCreateJoinBotton(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          overlay.size.width - 100,
          overlay.size.height - 200,
          100,
          100,
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'create',
          child: Row(
            children: const [
              Icon(Icons.group_add),
              SizedBox(width: 8),
              Text(
                "Tạo lớp",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'join',
          child: Row(
            children: const [
              Icon(Icons.qr_code_2),
              SizedBox(width: 8),
              Text(
                "Vào lớp",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (result == 'create') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateClassScreen()),
      );
    } else if (result == 'join') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JoinClassScreen()),
      );
    }
  }
}
