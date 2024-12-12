import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/colors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MoodLogPage extends StatefulWidget {
  final Function(int id, int emoticon, String text, String date)? onChoose;

  const MoodLogPage({super.key, this.onChoose});

  @override
  State<MoodLogPage> createState() => _MoodLogPageState();
}

class _MoodLogPageState extends State<MoodLogPage> {
  late Database database;
  List<Map<String, dynamic>> moodEntries = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  // Initialize SQLite database
  Future<void> _initializeDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'mood_log.db'),
      version: 1,
    );
    _loadMoodEntries();
  }

  // Load all mood entries from the database
  Future<void> _loadMoodEntries() async {
    final List<Map<String, dynamic>> entries =
    await database.query('mood_entries');
    setState(() {
      // moodEntries = entries;
      moodEntries = List<Map<String, dynamic>>.from(entries)
        ..sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      // moodEntries = entries
      //   ..sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/elips_result.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 120, left: 25),
                  child: _headTitle(),
                ),
              ],
            ),
            // const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: moodEntries.isEmpty
                    ? const Center(
                  child: Text(
                    "No mood history found!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: moodEntries.length,
                  itemBuilder: (context, index) {
                    final entry = moodEntries[index];
                    return GestureDetector(
                      onTap: () {
                        // Call the callback with selected data
                        widget.onChoose?.call(
                          entry['id'],
                          entry['emoticon'],
                          entry['text'],
                          entry['date'],
                        );
                      },
                      child: _buildMoodLogCard(
                        entry['text'],
                        entry['emoticon'],
                        entry['date'],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Align _headTitle() {
    return const Align(
      alignment: Alignment.topLeft,
      child: Text(
        "Mood Log",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }


  Widget _buildMoodLogCard(String text, int emoticonIndex, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xff82829E),
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  // date,
                  DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(date)),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index==0?Icons.sentiment_very_dissatisfied:
                    index==1?Icons.sentiment_dissatisfied:
                    index==2?Icons.sentiment_neutral:
                    index==3?Icons.sentiment_satisfied:
                    index==4?Icons.sentiment_very_satisfied:Icons.access_time


                    ,
                    color: index == emoticonIndex
                        ? Colors.amber //kPrimaryColor
                        : Colors.grey.shade300,
                  );
                }),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
