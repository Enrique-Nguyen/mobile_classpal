import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backgound_welcome.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: _currentPage < 2
                        ? TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signin');
                            },

                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFFD57662),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              "Bỏ qua",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : const SizedBox(height: 48),
                  ),
                ),

                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/images/logo_brand.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  'ClassPal',
                  style: GoogleFonts.dancingScript(
                    fontSize: 50,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E2D),
                  ),
                ),

                Expanded(
                  flex: 8,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildIntroSlide(),

                      _buildFeatureSlide(
                        title: 'Quản lý Hoạt động',
                        subtitle: 'Theo dõi nhiệm vụ & sự kiện dễ dàng',
                        content: Row(
                          children: [
                            Expanded(
                              child: _buildFeatureCard(
                                icon: Icons.check_circle_outline,
                                title: 'Nhiệm vụ',
                                subtitle: 'Theo dõi nhiệm vụ',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFeatureCard(
                                emoji: '🗓️',
                                title: 'Sự kiện',
                                subtitle: 'Đăng ký & Check-in',
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildFeatureSlide(
                        title: 'Tài chính & Tiện ích',
                        subtitle: 'Minh bạch quỹ lớp và trợ lý AI',
                        content: Row(
                          children: [
                            Expanded(
                              child: _buildFeatureCard(
                                emoji: '💰',
                                title: 'Quỹ lớp',
                                subtitle: 'Quản lý thu chi',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFeatureCard(
                                emoji: '🤖',
                                title: 'Chatbot',
                                subtitle: 'Chat tạo Task',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) => _buildDot(index)),
                      ),
                      const SizedBox(height: 30),
                      _buildGetStartedButton(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroSlide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text(
          'Học thật chất, quản lý phất,\nClassPal cân tất.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade700,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureSlide({
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E2D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 40),
        content,
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF4682A9)
            : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildFeatureCard({
    IconData? icon,
    String? emoji,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4682A9).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          if (icon != null)
            Icon(icon, size: 36, color: const Color(0xFF1E1E2D))
          else if (emoji != null)
            Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E2D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    bool isLastPage = _currentPage == 2;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (isLastPage) {
            Navigator.pushNamed(context, '/signin');
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isLastPage
              ? const Color(0xFF4682A9)
              : const Color(0xFF4682A9).withOpacity(0.9),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF4682A9).withOpacity(0.4),
        ),

        child: Text(
          isLastPage ? 'Khởi hành' : 'Tiếp tục',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
