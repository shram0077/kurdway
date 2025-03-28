import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Utils/texts.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  final String currentUserId;
  final UserModel userModel;

  const EditProfile({
    super.key,
    required this.userModel,
    required this.currentUserId,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  File? _image;
  bool isLoading = false;
  // List of quotes
  final List<String> quotes = [
    "A well-crafted profile can open doors to new opportunities.",
    "Your profile is your first impression—make it count!",
    "A strong profile shows passengers your professionalism and trustworthiness.",
    "Your profile reflects your quality—make it shine.",
    "A complete profile builds credibility and helps you connect better with passengers.",
    "Invest in your profile; it’s the first step towards gaining trust.",
    "Your profile is more than just details—it's your story to tell.",
    "A well-detailed profile speaks volumes about your quality and reliability.",
    "Every update to your profile is a step towards building trust with your passengers.",
    "Your profile is your online identity—ensure it tells the right story."
  ];

  // Function to get a random quote
  String getRandomQuote() {
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.userModel.name;
    emailController.text =
        widget.userModel.email.isEmpty ? '' : widget.userModel.email;
    phoneController.text = widget.userModel.phone.substring(4);
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return; // Prevents multiple calls

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile == null) return; // Prevents multiple replies

      setState(() {
        _image = File(croppedFile.path);
      });

      print("✅ Image successfully cropped: ${_image!.path}");
      _uploadProfilePicture(_image!);
    } catch (e) {
      print("❌ Error picking image: $e");
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    setState(() {
      isLoading = true;
    });
    var uploadServerInfo = await _getUploadServer();
    if (uploadServerInfo != null) {
      await _sendImageToServer(imageFile, uploadServerInfo['upload_url']!,
          uploadServerInfo['sess_id']!);
    } else {
      setState(() {
        isLoading = false;
      });
      print("Failed to get upload server information.");
    }
  }

  Future<Map<String, String>?> _getUploadServer() async {
    final url =
        Uri.parse('https://filelu.com/api/upload/server?key=${fileluApiKey}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'upload_url': responseData['result'],
          'sess_id': responseData['sess_id']
        };
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<void> _sendImageToServer(
      File imageFile, String uploadUrl, String sessId) async {
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..fields['sess_id'] = sessId
      ..fields['utype'] = 'prem'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responseData.body);
        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          var fileInfo = jsonResponse[0];
          if (fileInfo.containsKey('file_code')) {
            String fileCode = fileInfo['file_code'];
            String? downloadUrl = await _getDirectLink(fileCode);
            if (downloadUrl != null) {
              setState(() async {
                await usersRef
                    .doc(widget.userModel.userid)
                    .update({"profilePicture": downloadUrl.toString()});
                widget.userModel.profilePicture = downloadUrl;
                isLoading = false;
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<String?> _getDirectLink(String fileCode) async {
    final url = Uri.parse(
        'https://filelu.com/api/file/direct_link?key=${fileluApiKey}&file_code=$fileCode');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 200) {
          return responseData['result']['url'];
        }
      }
    } catch (e) {
      print('Error fetching direct link: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 55,
        title: robotoText("Edit Profile", whiteColor, 22, FontWeight.normal),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        backgroundColor: greenColor2,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                        child: LinearProgressIndicator(
                          color: greenColor2,
                        ),
                      )
                    : SizedBox(),
                robotoText(getRandomQuote(), blackColor.withOpacity(0.6), 16,
                    FontWeight.normal),
                const SizedBox(height: 20),
                _buildProfilePicture(),
                const SizedBox(height: 30),
                _buildTextField(
                    "Full Name", nameController, false, _validateName, true),
                _buildTextField(
                    widget.userModel.email.isEmpty
                        ? "Add E-mail"
                        : emailController.text,
                    emailController,
                    false,
                    _validateEmail,
                    true),
                _buildTextField("Phone Number", phoneController, true,
                    _validatePhone, false),
                const SizedBox(height: 35),
                !isLoading ? _buildButtons() : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              border: Border.all(
                  width: 4, color: Theme.of(context).scaffoldBackgroundColor),
              boxShadow: [
                BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 10),
                )
              ],
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: _image == null
                    ? CachedNetworkImageProvider(
                        widget.userModel.profilePicture)
                    : FileImage(_image!) as ImageProvider,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 4,
                      color: Theme.of(context).scaffoldBackgroundColor),
                  color: greenColor,
                ),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String labelText,
    TextEditingController controller,
    bool isPhoneField,
    String? Function(String?) validator,
    bool isEnabled,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        enabled: isEnabled,
        controller: controller,
        keyboardType: isPhoneField ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: labelText,
          hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.userModel.email.isEmpty
                  ? Colors.redAccent
                  : Colors.black),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MaterialButton(
          color: Colors.white60,
          padding: const EdgeInsets.symmetric(horizontal: 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL",
              style: TextStyle(
                  fontSize: 14, letterSpacing: 2.2, color: Colors.black)),
        ),
        MaterialButton(
          onPressed: () async {
            if (nameController.text.trim().isNotEmpty ||
                emailController.text.trim().isNotEmpty ||
                phoneController.text.trim().isNotEmpty) {
              if (_formKey.currentState!.validate()) {
                try {
                  await usersRef.doc(widget.userModel.userid).update({
                    if (nameController.text.trim().isNotEmpty)
                      "name": nameController.text.trim(),
                    if (emailController.text.trim().isNotEmpty)
                      "email": emailController.text.trim(),
                    if (phoneController.text.trim().isNotEmpty)
                      "phone": "+964${phoneController.text.trim()}",
                  });
                  print("Profile updated successfully.");
                } catch (e) {
                  print("Error updating profile: $e");
                }
              }
            }
          },
          color: greenColor2,
          padding: const EdgeInsets.symmetric(horizontal: 50),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Text("SAVE",
              style: TextStyle(
                  fontSize: 14, letterSpacing: 2.2, color: Colors.white)),
        ),
      ],
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(value)) {
        return 'Enter a valid email';
      }
    }
    return null; // Allow empty emails without validation
  }

  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^[0-9]{10}$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Enter a valid 10-digit phone number';
      }
    }
    return null; // Allow empty phone numbers without validation
  }
}
