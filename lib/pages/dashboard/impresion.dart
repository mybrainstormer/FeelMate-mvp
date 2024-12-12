import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/colors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart'; // New Package

class ImpresionPage extends StatefulWidget {
  final VoidCallback? onSaveComplete; // Callback for notifying parent widget

  const ImpresionPage({super.key, this.onSaveComplete});

  @override
  State<ImpresionPage> createState() => _ImpresionPageState();
}

class _ImpresionPageState extends State<ImpresionPage> {
  // Database instance
  late Database database;

  // Variables for state management
  int rating = 1; // Default rating is 0
  final TextEditingController _textController = TextEditingController();
  String formattedDate = '';

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    formattedDate = DateTime.now().toIso8601String();
  }

  // Initialize SQLite database
  Future<void> _initializeDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'mood_log.db');
    database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE mood_entries(id INTEGER PRIMARY KEY AUTOINCREMENT, emoticon INTEGER, text TEXT, date TEXT)',
        );
      },
    );

    // Ensure the table exists
    await database.execute(
      'CREATE TABLE IF NOT EXISTS mood_entries(id INTEGER PRIMARY KEY AUTOINCREMENT, emoticon INTEGER, text TEXT, date TEXT)',
    );
  }

  Future<void> _checkTableSchema() async {
    List<Map<String, dynamic>> result = await database.rawQuery(
        "PRAGMA table_info(mood_entries);"
    );
    for (var column in result) {
      print("Column: ${column['name']} Type: ${column['type']}");
    }
  }

  // Save mood entry to SQLite
  Future<void> _saveMoodEntry(BuildContext context) async {
    await _checkTableSchema();

    if (rating == 0 || _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an emoji and enter some text.')),
      );
      return;
    }

    await database.insert(
      'mood_entries',
      {
        'emoticon': rating,
        'text': _textController.text,
        'date': formattedDate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mood saved successfully!')),
    );

    // Trigger callback to notify the parent widget
    widget.onSaveComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/elips_result.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          // Emoji Feedback Widget
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 4,
                                  blurRadius: 10,
                                  offset: const Offset(3, 5),
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            padding: const EdgeInsets.all(16),
                            child: EmojiFeedback(
                              rating: rating, // Current rating value
                              emojiPreset: handDrawnEmojiPreset, // Emoji style preset
                              labelTextStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w400),
                              onChanged: (value) {
                                setState(() => rating = value??0);
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Input Container
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 4,
                                  blurRadius: 10,
                                  offset: const Offset(3, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(22),
                                  child: Stack(
                                    children: [
                                      // Text(
                                      //   'How is your day going? How has it affected your mood? Or anything else...',
                                      //   style: TextStyle(
                                      //     fontSize: 20,
                                      //     color: const Color(0xff82829E),
                                      //     fontFamily: GoogleFonts.poppins().fontFamily,
                                      //   ),
                                      //   textAlign: TextAlign.center,
                                      // ),
                                      // const SizedBox(height: 20),
                                      // Input field
                                      TextFormField(
                                        controller: _textController,
                                        style: const TextStyle(
                                          fontSize: 20, // Set font size to 20
                                          color: Colors.black, // Optional: Text color
                                        ),
                                        decoration: const InputDecoration(
                                          hintText:
                                          'How is your day going? How has it affected your mood? Or anything else...',
                                          // "Type your mood description here...",
                                          border: InputBorder.none,
                                          // border: OutlineInputBorder(
                                          //   borderRadius: BorderRadius.circular(8),
                                          // ),
                                        ),
                                        maxLines: 5,
                                      ),
                                      // const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Save Button
                          GestureDetector(
                            onTap: () {
                              _saveMoodEntry(context);
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: kPrimaryColor,
                              ),
                              width: double.infinity,
                              child: const Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
