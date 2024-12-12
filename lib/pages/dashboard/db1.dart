import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/pages/dashboard/impresion.dart';
import 'package:myapp/pages/dashboard/impression_view.dart';
import 'package:myapp/pages/dashboard/input_image.dart';
import 'package:myapp/pages/dashboard/mood_log.dart';
import 'package:myapp/pages/dashboard/resullt.dart';
import 'package:myapp/utils/colors.dart';
import 'package:flutter/services.dart'; // Required for minimizing app

class Db1 extends StatefulWidget {
  const Db1({super.key});

  @override
  State<Db1> createState() => _Db1State();
}

class _Db1State extends State<Db1> {
  int _currentIndex = 0;

  // List of pages for bottom navigation
  List<Widget> pages = [
    HomeContent(), // Home content inside db1.dart
    InputPage(),   // Scan - input_image.dart
    MoodLogPage(),  // Log - resullt.dart
    ImpresionPage(key:UniqueKey()), // Impresion Page
    Container(),// ResultPage(), // Impresion Page
    Container(),// ImpressionViewPage(key:UniqueKey(),date: '',emoticon: 0,id: 0,text: '',)
  ];

  // Method to handle navigation to ImpressionViewPage with data
  void _showImpressionViewPage({
    required int id,
    required int emoticon,
    required String text,
    required String date,
  }) {
    setState(() {
      pages[5] = ImpressionViewPage(
        id: id,
        emoticon: emoticon,
        text: text,
        date: date,
        onDeleteComplete: () {
          setState(() {
            pages[2] = MoodLogPage(key:UniqueKey(),
              onChoose: (id, emoticon, text, date) {
                // Trigger the method to display ImpressionViewPage
                _showImpressionViewPage(
                  id: id,
                  emoticon: emoticon,
                  text: text,
                  date: date,
                );
              },
            );; // Rebuild MoodLogPage
            _currentIndex = 2; // Navigate to MoodLogPage
          });
        },
      );
      _currentIndex = 5; // Set to ImpressionViewPage
    });
  }


  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if(index==1) pages[1] = InputPage(key:UniqueKey());
          if(index==2) {
            pages[2] = MoodLogPage(key: UniqueKey(),
              onChoose: (id, emoticon, text, date) {
                // Trigger the method to display ImpressionViewPage
                _showImpressionViewPage(
                  id: id,
                  emoticon: emoticon,
                  text: text,
                  date: date,
                );
              },
            );
          }
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _currentIndex == index ? kPrimaryColor : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _currentIndex == index ? kPrimaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pages[3] = ImpresionPage(key:UniqueKey(),
      onSaveComplete: () {
        print("_______ ON SAVE COMPLETE 79");
        setState(() {
          pages[2] = MoodLogPage(key:UniqueKey(),
            onChoose: (id, emoticon, text, date) {
              // Trigger the method to display ImpressionViewPage
              _showImpressionViewPage(
                id: id,
                emoticon: emoticon,
                text: text,
                date: date,
              );
            },
          );; // Rebuild MoodLogPage
          _currentIndex = 2; // Navigate to MoodLogPage
        });
      },
    );

    pages[2] = MoodLogPage(key:UniqueKey(),
      onChoose: (id, emoticon, text, date) {
        // Trigger the method to display ImpressionViewPage
        _showImpressionViewPage(
          id: id,
          emoticon: emoticon,
          text: text,
          date: date,
        );
      },
    );

    pages[1] = InputPage(key:UniqueKey(),
      onFinish: (message) {
        print("on finish input page:");
        setState(() {
          pages[4] = ResultPage(
            key: UniqueKey(),
            result: message,
          );
          _currentIndex = 4; // Set to ResultPage
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope( // Intercept back button press
      onWillPop: () async {
        // Minimize app when back is pressed
        SystemNavigator.pop(); // Minimize the app
        return false; // Prevent app exit
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex, // Keeps state when switching tabs
            children: pages,
          ),
        ),
// Custom Bottom Navigation Bar
          bottomNavigationBar: Stack(
            clipBehavior: Clip.none, // Allows overflow beyond the bottom nav bar
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.white, // Bottom bar background color
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildNavItem(Icons.home, "Home", 0),
                    const SizedBox(width: 40), // Empty space for FAB
                    _buildNavItem(Icons.access_time, "Mood Log", 2),
                  ],
                ),
              ),
              // Positioned FAB with offset to the top
              Positioned(
                top: -30, // Adjust this value for the desired offset (50% overlap)
                left: MediaQuery.of(context).size.width / 2 - 32, // Center horizontally
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      pages[1] = InputPage(key:UniqueKey(),
                        onFinish: (message) {
                          print("on finish input page:");
                          setState(() {
                            pages[4] = ResultPage(
                              key: UniqueKey(),
                              result: message,
                            );
                            _currentIndex = 4; // Set to ResultPage
                          });
                        },
                      );
                      _currentIndex = 1; // Navigate to InputPage
                    });
                  },
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),

      ),
    );
  }
}

// Extracted HomeContent to reuse the existing home UI
class HomeContent extends StatefulWidget {
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final List<String> quotes = [
    "You didn’t come this far to only come this far.",
    "The best way out is always through.",
    "Every day may not be good, but there’s something good in every day.",
  ];
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/elips_result.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildChatBubble(),
              const SizedBox(height: 30),
              _buildQuoteCarousel(),
              const SizedBox(height: 10),
              _buildDotsIndicator(),
              const SizedBox(height: 20),
              Text(
                "How are you feeling?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  // color: const Color(0xff1B4432),
                  color: const Color(0xff1B4432),
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              const SizedBox(height: 20),
              _buildButton("Let's write out about it", () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const ImpresionPage()),
                // );

                // Navigate to ImpresionPage within the bottom navigation
                // Navigator.of(context).pop(); // Close current overlay if any
                final parentState = context.findAncestorStateOfType<_Db1State>();
                parentState?.setState(() {
                  parentState.pages[3] = ImpresionPage(key:UniqueKey(),
                    onSaveComplete: () {
                      print("_______ ON SAVE COMPLETE 211");
                      final parentState = context.findAncestorStateOfType<_Db1State>();
                      parentState?.setState(() {
                        parentState.pages[2] = MoodLogPage(key:UniqueKey(),
                          onChoose: (id, emoticon, text, date) {
                            // Trigger the method to display ImpressionViewPage
                            parentState._showImpressionViewPage(
                              id: id,
                              emoticon: emoticon,
                              text: text,
                              date: date,
                            );
                          },
                        );; // Rebuild MoodLogPage
                        parentState._currentIndex = 2; // Navigate to MoodLogPage
                      });
                    },
                  );

                  parentState._currentIndex = 3; // Set to ImpresionPage
                });

              }),
              const SizedBox(height: 16),
              _buildButton("Let's find out what's your feeling", () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const InputPage()),
                // );
                final parentState = context.findAncestorStateOfType<_Db1State>();
                parentState?.setState(() {
                  parentState.pages[1] = InputPage(key:UniqueKey(),
                    onFinish: (message) {
                      print("on finish input page:");
                      final parentState = context.findAncestorStateOfType<_Db1State>();
                      parentState?.setState(() {
                        parentState.pages[4] = ResultPage(
                          key: UniqueKey(),
                          result: message,
                        );
                        parentState._currentIndex = 4; // Set to ResultPage
                      });
                    },
                  );


                  parentState._currentIndex = 1; // Set to InputPage
                });
              }),
            ],
          ),
        ),
      ],
    );
  }

  // Carousel of quotes
  Widget _buildQuoteCarousel() {
    return SizedBox(
      height: 120, // Carousel height
      child: PageView.builder(
        controller: _pageController,
        itemCount: quotes.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index; // Update the current page
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: const Color(0xff112233),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  quotes[index],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  // Dots Indicator
  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        quotes.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8,
          width: _currentPage == index ? 20 : 8, // Active dot is longer
          decoration: BoxDecoration(
            color: _currentPage == index ? kPrimaryColor : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  // Chat bubble widget
  Widget _buildChatBubble() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hey friends! :D",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.notoSans().fontFamily,
            ),
          ),
          Text(
            "Ready to lift your mood and vibe with us today?",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: GoogleFonts.notoSans().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Button widget
  Widget _buildButton(String text, VoidCallback ontap) {
    return ElevatedButton(
      onPressed: ontap,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
