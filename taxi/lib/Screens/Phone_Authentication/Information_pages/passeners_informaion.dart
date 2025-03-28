import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Screens/Phone_Authentication/OTP_Verification.dart';
import 'package:taxi/Utils/texts.dart';
import 'package:http/http.dart' as http;

class PassenersInformaion extends StatefulWidget {
  final String phoneNo;
  const PassenersInformaion(
      {super.key, required this.phoneNo, });
  @override
  State<PassenersInformaion> createState() => _PassenersInformaionState();
}

class _PassenersInformaionState extends State<PassenersInformaion> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? email;
  String? name;
  String? _selectedGender;
  bool isloading = false;
  String? profilePictureUri;
  // List of genders
  final List<String> _genders = [
    'Male',
    'Female',
  ];
  File? _image;
  String? filename;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        filename = File(pickedFile.name).toString();
      });
    }
  }

  void submitAction() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_image != null) {
        handleProfilePictureUpload(_image!, "33483if6tnlmefeenc68f");
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          isloading ? null : submitAction();

          //
        }, // Disable button when loading
        backgroundColor: splashGreenBGColor,
        child: isloading
            ? CircularProgressIndicator()
            : Icon(
                CupertinoIcons.arrow_right,
                color: whiteColor,
              ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: robotoText("Informations", blackColor, 20, FontWeight.w500),
        backgroundColor: whiteColor,
        elevation: 0.8,
      ),
      body: ListView(
        children: [
          Padding(
              padding: const EdgeInsets.only(
                top: 12.0,
                left: 12,
              ),
              child: robotoText(
                  "Create Your Profile", blackColor, 32, FontWeight.normal)),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 18, top: 5),
            child: robotoText(
                "Tell us a little about yourself, and we’ll get you set up.",
                blackColor.withOpacity(0.6),
                16,
                FontWeight.normal),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
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
                              offset: Offset(0, 10))
                        ],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _image == null
                                ? AssetImage("assets/images/user_avatar.png")
                                : FileImage(_image!))),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                        },
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
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 50),
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        onChanged: (value) {
                          name = value;
                        },
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          hintText: 'e.g. Ali Kareem',
                          hintStyle: GoogleFonts.roboto(
                              color: blackColor.withOpacity(0.3),
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(
                                color: splashGreenBGColor, width: 2.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        email = value;
                      },
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'e.g. example@gmail.com',
                        hintStyle: GoogleFonts.roboto(
                            color: blackColor.withOpacity(0.3),
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: splashGreenBGColor, width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        // Regular expression for validating email format
                        String pattern =
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: _genders.map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a gender';
                        }
                        return null;
                      },
                    ),
                  ],
                )),
          )
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
          'sess_id': responseData['sess_id']
        };
      } else {
        print('Failed to fetch upload server: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      print('Error: $e');
      return null;
    }
  }

  Future<void> handleProfilePictureUpload(File imageFile, String apiKey) async {
    setState(() {
      isloading = true;
    });
    var uploadServerInfo = await getUploadServer(apiKey);
    if (uploadServerInfo != null) {
      await uploadProfilePicture(imageFile, uploadServerInfo['upload_url']!,
          uploadServerInfo['sess_id']!, apiKey);
    } else {
      setState(() {
        isloading = false;
      });
      print("Failed to get upload server information.");
    }
  }

  Future<void> uploadProfilePicture(
      File imageFile, String uploadUrl, String sessId, apiKey) async {
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..fields['sess_id'] = sessId
      ..fields['utype'] = 'prem'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path,
          filename: "${widget.phoneNo}.jpg"));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);

        try {
          var jsonResponse = jsonDecode(responseData.body);

          if (jsonResponse is List && jsonResponse.isNotEmpty) {
            var fileInfo = jsonResponse[0]; // Access the first map in the list
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
            print("Unexpected response structure: ${responseData.body}");
          }
        } catch (e) {
          print("Error parsing JSON: $e");
        }

        setState(() {
          isloading = false;
        });
      } else {
        setState(() {
          isloading = false;
        });
        print("Upload failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      print("Error uploading image: $e");
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
          // Extract the direct download URL
          var result = responseData['result'];
          String downloadUri = result['url']; // This is the direct download URL
          setState(() {
            profilePictureUri = downloadUri;
          });
          print("Direct download URI: $profilePictureUri");

          Navigator.push(
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
          // return downloadUri;
          return responseData['direct_link'];
        } else {
          print('Failed to fetch direct link: ${responseData['msg']}');
          return null;
        }
      } else {
        print('Failed to get direct link: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching direct link: $e');
      return null;
    }
  }
}
