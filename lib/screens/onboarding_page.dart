import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
  final PageController _controller = PageController();

  // 📦 DATA: The content for the 3 slides
  final List<Map<String, String>> _content = [
    {
      "image": "https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=800&q=80",
      "title": "Discover Trends",
      "desc": "Explore the latest fashion trends and shop from a wide collection of top brands."
    },
    {
      "image": "https://images.unsplash.com/photo-1556742049-0cfed4f7a07d?auto=format&fit=crop&w=800&q=80",
      "title": "Easy Payment",
      "desc": "Experience seamless and secure checkout with multiple payment options."
    },
    {
      "image": "https://images.unsplash.com/photo-1601933973783-43cf8a7d4c5f?auto=format&fit=crop&w=800&q=80",
      "title": "Fast Delivery",
      "desc": "Get your order delivered to your doorstep in record time with live tracking."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. PAGE SLIDER ---
          PageView.builder(
            controller: _controller,
            itemCount: _content.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Column(
                children: [
                  // Top Image Section (60% of screen)
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(_content[index]['image']!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                      // Dark overlay for status bar readability
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black45, Colors.transparent],
                            stops: [0.0, 0.3],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Empty space for the bottom text sheet
                  Expanded(flex: 4, child: SizedBox()),
                ],
              );
            },
          ),

          // --- 2. BOTTOM TEXT SHEET ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text Content
                  Column(
                    children: [
                      Text(
                        _content[_currentPage]['title']!,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 15),
                      Text(
                        _content[_currentPage]['desc']!,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // Indicators & Button
                  Column(
                    children: [
                      // Dot Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _content.length,
                          (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? Colors.indigo : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      
                      // Main Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _content.length - 1) {
                              // Last Page -> Go to Login
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
                            } else {
                              // Next Page
                              _controller.nextPage(duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage == _content.length - 1 ? "Get Started" : "Next",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // --- 3. SKIP BUTTON (Top Right) ---
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage())),
              child: Text(
                "Skip",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}