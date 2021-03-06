import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as sysPath;
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:event_listener/event_listener.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'com.google.firebase.database.ValueEventListener';

import './tabs_screen.dart';
import './signup_screen.dart';

import '../providers/user_details.dart';
import '../providers/auth_details.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/login-screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final ekalVidyalayaImage = 'assets/images/Ekal-Vidyalaya.jpg';
  final aurigaCareImage = 'assets/images/ac_logo.png';
  late AnimationController _animeController;
  late Animation<Size> _heightAnimation;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Provider.of<AuthDetails>(context, listen: false)
        .getExistingUserPhoneNumbers();
  }

  bool _isOtpSent = false;
  bool _isAuthenticationAccepted = false;
  bool _showLoading = false;
  bool _userVerified = false;
  bool _userExists = false;
  bool _signInClicked = false;
  bool _submitOtpClicked = false;

  String _verificationId = "";
  TextEditingController _userPhoneNumber = TextEditingController();
  TextEditingController _userOtpValue = TextEditingController();
  TextEditingController _otpValue = TextEditingController();

  Future<void> _checkIfUserExists(BuildContext context) async {
    // var currLoggedInUser = await FirebaseAuth.instance.currentUser;
    // var loggedInUserId = currLoggedInUser?.uid as String;
    // DatabaseReference rootRef = await FirebaseDatabase.instance.reference();
    // DatabaseReference uidRef = rootRef.child("UsersPhoneNumber").child(loggedInUserId);
    // final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: '');
  }

  Future<void> _userSignIn(
    BuildContext context,
    TextEditingController userPhoneNumber,
  ) async {
    if (userPhoneNumber.text.length != 10) {
      String titleText = "Invild Mobile Number";
      String contextText = "Please Enter a Valid 10 Digit Number!";
      _checkForError(context, titleText, contextText);
    } else if (int.tryParse(userPhoneNumber.text) == null) {
      String titleText = "Invild Mobile Number";
      String contextText = "Entered Number is Not Valid!";
      _checkForError(context, titleText, contextText);
    } else if (int.parse(userPhoneNumber.text) < 0) {
      String titleText = "Invild Mobile Number";
      String contextText = "Mobile Number Cannot be Negative!";
      _checkForError(context, titleText, contextText);
    } else {
      // String titleText = "Authentication";
      // String contextText = "Enter the Otp:";
      // _checkIfUserExists(context);
      // _enterUserOtp(context, titleText, contextText);

      if ((await Provider.of<AuthDetails>(context, listen: false)
              .checkIfEnteredNumberExists(context, userPhoneNumber)) ==
          true) {
        print('User Already Exists!');

        setState(() {
          _showLoading = true;
          _signInClicked = true;
        });

        _scaffoldKey.currentState?.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Verifiying your Phone Number..."),
          ),
        );

        _checkForAuthentication(context, _userPhoneNumber);
      } else {
        print("New User!");

        String titleText = "New User";
        String contextText =
            "Please Create your Account!\n??????????????? ???????????? ???????????? ??????????????????";
        _checkForError(context, titleText, contextText);
      }
    }
  }

  // Future<void> _otpVerification(BuildContext context)
  Future<void> openOtpWidget() async {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("Otp Sent!"),
      ),
    );
    String titleText = "Mobile Authentication";
    String contextText = "Enter the Otp:";
    _enterUserOtp(context, titleText, contextText);
  }

  Future<void> _enterUserOtp(
    BuildContext context,
    String titleText,
    String contextText,
  ) async {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${titleText}'),
        content: Text('${contextText}'),
        actions: <Widget>[
          Container(
            height: screenHeight * 0.2,
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade100,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            margin: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  maxLength: 6,
                  decoration: InputDecoration(labelText: 'Enter the OTP: '),
                  controller: _userOtpValue,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) {},
                ),
              ],
            ),
          ),
          RaisedButton(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.5),
            ),
            color: Colors.blue.shade400,
            child: Text('Submit Otp'),
            onPressed: () async {
              PhoneAuthCredential phoneAuthCredential =
                  PhoneAuthProvider.credential(
                verificationId: this._verificationId,
                smsCode: _userOtpValue.text,
              );
              _scaffoldKey.currentState?.showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text("Verifying the Entered Otp..."),
                ),
              );
              signInWithPhoneAuthCred(context, phoneAuthCredential);
              Navigator.of(ctx).pop(false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _checkForAuthentication(
    BuildContext context,
    TextEditingController phoneController,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text}",

      // Setting the Otp Timeout Duration
      timeout: Duration(seconds: 60),

      // After the Authentication has been Completed Successfully
      verificationCompleted: (phoneAuthCredential) async {
        setState(() {
          _isAuthenticationAccepted = true;
          print('auth successful');
        });
        // signInWithPhoneAuthCred(context, phoneAuthCredential);
      },

      // After the Authentication has been Failed/Declined
      verificationFailed: (verificationFailed) async {
        setState(() {
          _isOtpSent = false;
          _isAuthenticationAccepted = false;
          _showLoading = false;
          _signInClicked = false;
          _submitOtpClicked = false;
        });
        print('verification failed');
        print(verificationFailed);

        String titleText = "Authenticatoin Failed!";
        String contextText = "Unable to generate the OTP.";
        _checkForError(context, titleText, contextText);

        _scaffoldKey.currentState?.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("${contextText}"),
          ),
        );
      },

      // After the OTP has been sent to Mobile Number Successfully
      codeSent: (verificationId, resendingToken) async {
        print('otp sent');
        openOtpWidget();

        setState(() {
          _isOtpSent = true;
          _isAuthenticationAccepted = false;
          _showLoading = false;

          this._verificationId = verificationId;
        });
      },

      // After the Otp Timeout period
      codeAutoRetrievalTimeout: (verificationID) async {
        setState(() {
          _isOtpSent = false;
          _isAuthenticationAccepted = false;
          _showLoading = false;
          _signInClicked = false;
        });

        if (!_userVerified) {
          String titleText = "Authenticatoin Timeout!";
          String contextText = "Please Re-Try Again";
          _checkForError(context, titleText, contextText);
        }
      },
    );
  }

  void signInWithPhoneAuthCred(
    BuildContext context,
    PhoneAuthCredential phoneAuthCredential,
  ) async {
    setState(() {
      _showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        _showLoading = false;
      });

      if (authCredential.user != null) {
        print('authentication complete!');
        setState(() {
          _userVerified = true;
          _isOtpSent = false;
          _isAuthenticationAccepted = false;
          _showLoading = false;
          _userExists = false;
          _signInClicked = false;
          _submitOtpClicked = false;
        });

        // Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
        Navigator.of(context)
            .pushNamedAndRemoveUntil("/tab-screen", (route) => false);
      }
    } on FirebaseAuthException catch (errorVal) {
      print(errorVal);

      if (_isOtpSent) {
        setState(() {
          _signInClicked = false;
          _submitOtpClicked = false;
          _showLoading = false;
        });

        String titleText = "Authentication Failed!";
        String contextText =
            "Entered Otp is InValid!\n???????????? ???????????? ????????? ??????????????? ?????????????????? ?????????";
        _checkForError(context, titleText, contextText);

        print(errorVal.message);
      }
    }
  }

  Future<void> _checkForError(
      BuildContext context, String titleText, String contextText,
      {bool popVal = false}) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${titleText}'),
        content: Text('${contextText}'),
        actions: <Widget>[
          RaisedButton(
            child: Text('OK'),
            onPressed: () {
              if (popVal == false) {
                Navigator.of(ctx).pop(false);
              }
            },
          ),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white70,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: screenHeight * 0.045,
              ),
              Container(
                // decoration: BoxDecoration(color: Colors.blue),
                child: Image.asset(
                  ekalVidyalayaImage,
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.2,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.001,
              ),
              Container(
                color: Colors.blue.shade200,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01,
                    horizontal: screenWidth * 0.025,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Text(
                    'Ekal Attendence App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.035,
                      decorationStyle: TextDecorationStyle.wavy,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Container(
                alignment: Alignment.center,
                color: Colors.white70,
                height: screenHeight * 0.4,
                width: screenWidth * 0.9,
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Card(
                      elevation: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade100,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.02,
                        ),
                        margin: EdgeInsets.all(screenWidth * 0.02),
                        child: TextField(
                          maxLength: 10,
                          decoration: InputDecoration(
                              labelText: 'Mobile Number/?????????????????? ????????????: '),
                          controller: _userPhoneNumber,
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) {},
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.025,
                    ),
                    ButtonTheme(
                      minWidth: screenWidth * 0.5,
                      height: screenHeight * 0.07,
                      child: RaisedButton(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.5),
                        ),
                        child: !_signInClicked
                            ? Text(
                                'Sign-In',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenHeight * 0.025,
                                  color: Colors.white,
                                ),
                              )
                            : CircularProgressIndicator(
                                color: Colors.white,
                              ),
                        onPressed: () async {
                          _userSignIn(context, _userPhoneNumber);
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.005,
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(SignUpScreen.routeName);
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.025,
              ),
              Container(
                child: Text(
                  "Developed Under:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                // decoration: BoxDecoration(color: Colors.blue),
                child: Image.asset(
                  aurigaCareImage,
                  width: screenWidth * 0.75,
                  height: screenHeight * 0.075,
                ),
              ),
              // SizedBox(
              //   height: screenHeight * 0.12,
              // ),
              Container(
                margin: EdgeInsets.only(
                  // left: screenWidth * 0.45,
                  // right: screenWidth * 0.01,
                  top: screenHeight * 0.0025,
                  bottom: screenHeight * 0.0025,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.025,
                  vertical: screenHeight * 0.01,
                ),
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "",
                        style: TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      WidgetSpan(
                        child: Icon(
                          Icons.ads_click_rounded,
                        ),
                      ),
                      TextSpan(
                        // style: linkText,
                        text: "  --Website Link--",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            var url = "https://ail.auriga.co.in";
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.15,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: screenWidth * 0.45,
                  right: screenWidth * 0.01,
                  top: screenHeight * 0.0025,
                  bottom: screenHeight * 0.0025,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.025,
                  vertical: screenHeight * 0.01,
                ),
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Developer: ",
                        style: TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      WidgetSpan(
                        child: Icon(
                          Icons.ads_click_rounded,
                        ),
                      ),
                      TextSpan(
                        // style: linkText,
                        text: "Rahul Singh",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            var url =
                                "https://www.linkedin.com/in/rahul-singh-3003811b1/";
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
