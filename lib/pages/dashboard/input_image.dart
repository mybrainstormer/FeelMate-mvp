import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/pages/dashboard/resullt.dart';
import 'package:myapp/utils/colors.dart';
import 'package:image_picker/image_picker.dart';

class InputPage extends StatefulWidget {
  final Function(String result)? onFinish;
  const InputPage({super.key,this.onFinish});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  File? _image;
  bool _isUploading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  initState(){
    super.initState();
    if(widget.onFinish==null) print("NULL");
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      var uri = Uri.parse(
          'https://emotion-based-game-model-185908856851.asia-southeast2.run.app/recommend');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseString);

        // Show dialog with API result
        _showDialog(jsonResponse.toString(), responseString);
      } else {
        _showError('Failed to upload image. Please try again.');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showDialog(String message, String fullResult) async {
    print("message");
    print(message);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Info"),
        content: const Text("your recommendataion is ready, press OK to see the result!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // // Navigate to result page and pass result
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => ResultPage(result: fullResult)),
              // );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
    print("hello1");
    widget.onFinish?.call(
      fullResult
    );
    print("hello2");


  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 21, vertical: 24),
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
                                  margin: const EdgeInsets.only(
                                      left: 31, top: 31, right: 31),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Input your picture here',
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(179, 0, 0, 0)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24),
                                        child: GestureDetector(
                                          onTap: _pickImage,
                                          child: _image == null
                                              ? Image.asset('assets/input.png')
                                              : Container(
                                            width: double.infinity, // Set the container to full width
                                            constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context).size.height * 0.8, // Limit height
                                            ),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical, // Enable vertical scrolling
                                              child: Image.file(
                                                _image!,
                                                fit: BoxFit.contain, // Keep image aspect ratio
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Please wait for activity recommendations to lift your spirits and boost your mood!',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black54),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // const SizedBox(height: 30),
                          _isUploading
                              ? const CircularProgressIndicator()
                              : GestureDetector(
                            onTap: _uploadImage,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: kPrimaryColor),
                              width: double.infinity,
                              child: const Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
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
