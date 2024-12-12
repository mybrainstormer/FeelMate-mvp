import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/colors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart'; // Emoji Feedback Package

class ImpressionViewPage extends StatefulWidget {
  final int id;
  final int emoticon; // Emoticon rating value
  final String text;
  final String date;
  final VoidCallback? onDeleteComplete; // Callback for notifying parent widget

  const ImpressionViewPage({
    super.key,
    required this.id,
    required this.emoticon,
    required this.text,
    required this.date,
    this.onDeleteComplete,
  });

  @override
  State<ImpressionViewPage> createState() => _ImpressionViewPageState();
}

class _ImpressionViewPageState extends State<ImpressionViewPage> {
  // Delete the entry from the database
  Future<void> _deleteEntry(BuildContext context) async {
    final dbPath = join(await getDatabasesPath(), 'mood_log.db');
    final db = await openDatabase(dbPath);

    await db.delete('mood_entries', where: 'id = ?', whereArgs: [widget.id]);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry deleted successfully!')),
    );

    // Trigger the delete completion callback
    widget.onDeleteComplete?.call();
  }

  Align _headTitle() {
    return const Align(
      alignment: Alignment.topLeft,
      child: Text(
        "Current Mood Log",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this entry? This action cannot be undone."),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            // Confirm Delete Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteEntry(context); // Call the delete method
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
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
                    child: Column(
                      children: [
                        _headTitle(),
                        const SizedBox(height: 20),
                        // Emoji Feedback Display
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
                            rating: widget.emoticon+1, // Set rating to passed value
                            emojiPreset: handDrawnEmojiPreset, // Use hand-drawn style
                            labelTextStyle: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Display Text Container
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
                          // margin: const EdgeInsets.symmetric(horizontal: 22),
                          padding: const EdgeInsets.all(16),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(),
                              Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: const Color(0xff82829E),
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.date,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align buttons properly
                          children: [
                            // Delete Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showDeleteConfirmationDialog(context),
                                child: Container(
                                  height: 50,
                                  margin: const EdgeInsets.only(right: 8), // Spacing between buttons
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: kPrimaryColor, // Same color for both buttons
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Back Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  widget.onDeleteComplete?.call();
                                },
                                child: Container(
                                  height: 50,
                                  margin: const EdgeInsets.only(left: 8), // Spacing between buttons
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: kPrimaryColor, // Same color for both buttons
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Back',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Delete Button
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
