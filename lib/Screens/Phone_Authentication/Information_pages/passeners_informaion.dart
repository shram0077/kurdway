import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart'; // <-- dio import added
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Screens/Phone_Authentication/OTP_Verification.dart';
import 'package:taxi/Utils/texts.dart';

class PassenersInformaion extends StatefulWidget {
  final String phoneNo;
  const PassenersInformaion({super.key, required this.phoneNo});

  @override
  State<PassenersInformaion> createState() => _PassenersInformaionState();
}

class _PassenersInformaionState extends State<PassenersInformaion> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? name;
  String? email;
  String? _selectedGender;
  bool isLoading = false;
  double uploadProgress = 0.0; // <-- New progress state
  String? profilePictureUri;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final List<String> _genders = ['Male', 'Female'];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Image pick error: $e");
    }
  }

  Future<void> submitAction() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_image != null) {
        await handleProfilePictureUpload(_image!, "33483if6tnlmefeenc68f");
      } else {
        _showSnackBar("Please select a profile picture.");
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : submitAction,
        backgroundColor: splashGreenBGColor,
        child: isLoading
            ? Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                    value: uploadProgress > 0 ? uploadProgress : null,
                    strokeWidth: 3,
                  ),
                  if (uploadProgress > 0)
                    Text(
                      '${(uploadProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                ],
              )
            : const Icon(CupertinoIcons.arrow_right, color: Colors.white),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: robotoText("Informations", blackColor, 20, FontWeight.w500),
        backgroundColor: whiteColor,
        elevation: 0.8,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          const SizedBox(height: 12),
          robotoText("Create Your Profile", blackColor, 32, FontWeight.normal),
          const SizedBox(height: 5),
          robotoText(
            "Tell us a little about yourself, and we’ll get you set up.",
            blackColor.withOpacity(0.6),
            16,
            FontWeight.normal,
          ),
          const SizedBox(height: 18),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 4,
                        color: Theme.of(context).scaffoldBackgroundColor),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 2,
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 10),
                      ),
                    ],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _image == null
                          ? const AssetImage("assets/images/user_avatar.png")
                              as ImageProvider
                          : FileImage(_image!),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        color: Colors.green,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Ali Kareem',
                    hintStyle: GoogleFonts.roboto(
                        color: blackColor.withOpacity(0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      borderSide:
                          BorderSide(color: splashGreenBGColor, width: 2.0),
                    ),
                  ),
                  onChanged: (value) => name = value.trim(),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter your name'
                      : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'e.g. example@gmail.com',
                    hintStyle: GoogleFonts.roboto(
                        color: blackColor.withOpacity(0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      borderSide:
                          BorderSide(color: splashGreenBGColor, width: 2.0),
                    ),
                  ),
                  onChanged: (value) => email = value.trim(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    final pattern =
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                    final regex = RegExp(pattern);
                    if (!regex.hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: _genders
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a gender' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<Map<String, String>?> getUploadServer(String apiKey) async {
    final url = Uri.parse('https://filelu.com/api/upload/server?key=$apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'upload_url': responseData['result'],
          'sess_id': responseData['sess_id'],
        };
      } else {
        print('Failed to fetch upload server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching upload server: $e');
    }
    if (mounted) setState(() => isLoading = false);
    return null;
  }

  Future<void> handleProfilePictureUpload(File imageFile, String apiKey) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      uploadProgress = 0.0;
    });

    final uploadServerInfo = await getUploadServer(apiKey);
    if (uploadServerInfo != null) {
      await uploadProfilePicture(imageFile, uploadServerInfo['upload_url']!,
          uploadServerInfo['sess_id']!, apiKey);
    } else {
      _showSnackBar("Failed to get upload server information.");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> uploadProfilePicture(
      File imageFile, String uploadUrl, String sessId, String apiKey) async {
    try {
      Dio dio = Dio();

      FormData formData = FormData.fromMap({
        'sess_id': sessId,
        'utype': 'prem',
        'file': await MultipartFile.fromFile(imageFile.path,
            filename: "${widget.phoneNo}.jpg"),
      });

      var response = await dio.post(
        uploadUrl,
        data: formData,
        onSendProgress: (int sent, int total) {
          double progress = sent / total;
          if (mounted) {
            setState(() {
              uploadProgress = progress;
            });
          }
          print("Upload progress: ${(progress * 100).toStringAsFixed(0)}%");
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          var fileInfo = jsonResponse[0];
          if (fileInfo.containsKey('file_code')) {
            String fileCode = fileInfo['file_code'];
            print("Upload successful, file code: $fileCode");

            String? downloadUrl = await getDirectLink(apiKey, fileCode);
            if (downloadUrl != null) {
              print("Download link: $downloadUrl");
            }
          } else {
            print("file_code not found in response.");
          }
        } else {
          print("Unexpected response structure: $jsonResponse");
        }
      } else {
        print("Upload failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading image: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          uploadProgress = 0.0;
        });
      }
    }
  }

  Future<String?> getDirectLink(String apiKey, String fileCode) async {
    final url = Uri.parse(
        'https://filelu.com/api/file/direct_link?key=$apiKey&file_code=$fileCode');
    print("Fetching direct file link from: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Direct link response: $responseData");

        if (responseData['status'] == 200) {
          final result = responseData['result'];
          final downloadUri = result['url'] as String?;

          if (downloadUri != null) {
            if (mounted) {
              setState(() => profilePictureUri = downloadUri);
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: OtpVerification(
                    isDriver: false,
                    phoneNo: widget.phoneNo,
                    carBM: '',
                    gender: _selectedGender!,
                    isRegistered: false,
                    licensePlate: '',
                    name: name!,
                    profilePictureUri: downloadUri,
                  ),
                ),
              );
            }
            return downloadUri;
          }
        } else {
          print('Failed to fetch direct link: ${responseData['msg']}');
        }
      } else {
        print('Failed to get direct link: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching direct link: $e');
    }
    return null;
  }
}
