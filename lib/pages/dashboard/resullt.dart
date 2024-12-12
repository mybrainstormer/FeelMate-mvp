import 'dart:convert';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String result;

  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Check for null or empty response
    if (result.isEmpty || result == "null") {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              'No Results Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
        ),
      );
    }

    // Decode the result JSON to a usable map
    Map<String, dynamic> data;
    try {
      data = jsonDecode(result);
    } catch (e) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              'Invalid Data Format',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
        ),
      );
    }

    final String emotion = data['emotion'] ?? 'Unknown';
    final List<dynamic> recommendations = data['recommendations'] ?? [];

    FocusScope.of(context).unfocus();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Mood Display Section
              Stack(
                children: [
                  Image.asset(
                    'assets/elips_result.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 21, vertical: 24),
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
                                  margin: const EdgeInsets.all(31),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Your Current Mood is $emotion',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Icon(
                                        Icons.sentiment_satisfied,
                                        size: 140,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Here are some activities we recommend to help lift your mood and make you feel better!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Recommendations Section
              recommendations.isEmpty
                  ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'No Recommendations Available',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Wrap(
                  spacing: 16, // Horizontal spacing
                  runSpacing: 16, // Vertical spacing
                  alignment: WrapAlignment.start, // Aligns items to the left
                  children:
                  [
                    ...recommendations.map<Widget>((recommendation) {
                      return Container(
                        // width: recommendations.length == 1
                        //     ? double.infinity // Full width if only 1 item
                        //     : MediaQuery.of(context).size.width / 2 - 24, // Half width for multiple items
                        width:MediaQuery.of(context).size.width / 2 - 24, // Half width for multiple items
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Placeholder for an image
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 4,
                                    blurRadius: 10,
                                    offset: const Offset(3, 5),
                                  ),
                                ],

                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recommendation['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Price: \$${recommendation['price']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if(recommendations.length == 1)
                      Container(
                        // width: recommendations.length == 1
                        //     ? double.infinity // Full width if only 1 item
                        //     : MediaQuery.of(context).size.width / 2 - 24, // Half width for multiple items
                        width:MediaQuery.of(context).size.width / 2 - 24, // Half width for multiple items
                        child: Column()
                      ),
                  ]

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
