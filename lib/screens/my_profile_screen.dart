import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:url_launcher/url_launcher.dart';

import '../providers/user_details.dart';

class MyProfile extends StatefulWidget {
  static const routeName = '/my-profile';
  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  TextEditingController _designationType = TextEditingController();
  TextEditingController _designationRoleType = TextEditingController();
  TextEditingController _dayitvaType = TextEditingController();

  TextEditingController _PrabagLocationType = TextEditingController();
  TextEditingController _SambhagLocationType = TextEditingController();
  TextEditingController _BhagLocationType = TextEditingController();
  TextEditingController _AnchalLocationType = TextEditingController();
  TextEditingController _ClusterLocationType = TextEditingController();
  TextEditingController _SanchLocationType = TextEditingController();
  TextEditingController _UpSanchLocationType = TextEditingController();
  TextEditingController _VillageLocationType = TextEditingController();

  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _age = TextEditingController();
  TextEditingController _gender = TextEditingController();
  TextEditingController _dateOfBirth = TextEditingController();
  TextEditingController _eduQualification = TextEditingController();
  TextEditingController _homeAddress = TextEditingController();
  TextEditingController _schoolAddress = TextEditingController();
  TextEditingController _mobileNumber = TextEditingController();
  TextEditingController _postalCode = TextEditingController();

  // TextEditingController _stateName = TextEditingController();
  // TextEditingController _regionName = TextEditingController();
  // TextEditingController _districtName = TextEditingController();
  // TextEditingController _anchalName = TextEditingController();
  // TextEditingController _sankulName = TextEditingController();
  // TextEditingController _clusterName = TextEditingController();
  // TextEditingController _subClusterName = TextEditingController();
  // TextEditingController _villageName = TextEditingController();

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();

  // }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    var topInsets = MediaQuery.of(context).viewInsets.top;
    var bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    var useableHeight = screenHeight - topInsets - bottomInsets;

    var userInfoDetails = Provider.of<UserDetails>(context);
    Map<String, String> userMapping =
        userInfoDetails.getUserPersonalInformation();
    String subDesignationType = "";
    bool _isAcharyaInfo = false;

    if (userMapping["designation_Type"] == "Acharya -- ??????????????????") {
      _isAcharyaInfo = true;
    }

    if (userMapping["designation_RoleType"] == "Karyakarta -- ??????????????????????????????") {
      subDesignationType = "Karyakarta Type  \n?????????????????????????????? ??????????????????";
    } else if (userMapping["designation_RoleType"] == "Samiti -- ???????????????") {
      subDesignationType = "Samiti Type  \n??????????????? ??????????????????";
    } else {
      subDesignationType = "Acharya Type  \n?????????????????? ??????????????????";
    }

    bool _isPrabhagVisible = false;
    bool _isSambhagVisible = false;
    bool _isBhagVisible = false;
    bool _isAnchalVisible = false;
    bool _isClusterVisible = false;
    bool _isSanchVisible = false;
    bool _isUpSanchVisible = false;
    bool _isVillageVissible = false;

    if (userMapping["village_LevelType"].toString().length != 0) {
      _isPrabhagVisible = true;
      _isSambhagVisible = true;
      _isBhagVisible = true;
      _isAnchalVisible = true;
      _isClusterVisible = true;
      _isSanchVisible = true;
      _isUpSanchVisible = true;
      _isVillageVissible = true;
    } else if (userMapping["upSanch_LevelType"].toString().length != 0) {
      _isPrabhagVisible = true;
      _isSambhagVisible = true;
      _isBhagVisible = true;
      _isAnchalVisible = true;
      _isClusterVisible = true;
      _isSanchVisible = true;
      _isUpSanchVisible = true;
    } else if (userMapping["sanch_LevelType"].toString().length != 0) {
      _isPrabhagVisible = true;
      _isSambhagVisible = true;
      _isBhagVisible = true;
      _isAnchalVisible = true;
      _isClusterVisible = true;
      _isSanchVisible = true;
    } else if (userMapping["cluster_LevelType"].toString().length != 0) {
      _isPrabhagVisible = true;
      _isSambhagVisible = true;
      _isBhagVisible = true;
      _isAnchalVisible = true;
      _isClusterVisible = true;
    } else if (userMapping["anchal_LevelType"].toString().length != 0) {
      _isPrabhagVisible = true;
      _isSambhagVisible = true;
      _isBhagVisible = true;
      _isAnchalVisible = true;
    } else if (userMapping["bhag_LevelType"].toString().length != 0) {
      _isPrabhagVisible = true;
      _isSambhagVisible = true;
      _isBhagVisible = true;
    } else if (userMapping["sambhag_LevelType"].toString().length != 0) {
      _isPrabhagVisible = true;
      _isSambhagVisible = true;
    } else if (userMapping["prabhag_LevelType"].toString().length != 0) {
      _isPrabhagVisible = true;
    }

    bool _isDesignatoinTypeSet = false;
    bool _isDesignationRoleTypeSet = false;
    bool _isDayitvaTypeSet = false;

    bool _isPrabagLocationTypeSet = false;
    bool _isSambhagLocationTypeSet = false;
    bool _isBhagLocationTypeSet = false;
    bool _isAnchalLocationTypeSet = false;
    bool _isClusterLocationTypeSet = false;
    bool _isSanchLocationTypeSet = false;
    bool _isUpSanchLocationTypeSet = false;
    bool _isVillageLocationTypeSet = false;

    bool _isFirstNameSet = false;
    bool _isLastNameSet = false;
    bool _isAgeSet = false;
    bool _isGenderSet = false;
    bool _isDateTimeSet = false;
    bool _isHomeAddressSet = false;
    bool _isSchoolAddressSet = false;
    bool _isMobileNumberSet = false;
    bool _isPostalCodeSet = false;
    bool _isEducationQualificationSet = false;

    _designationType.text = "Getting Designation...";
    _designationRoleType.text = "Getting Designation Role Type...";
    _dayitvaType.text = "Getting Dayitva Type...";

    _firstName.text = "Getting First Name...";
    _lastName.text = "Getting Last Name...";
    _age.text = "Getting Age...";
    _gender.text = "Getting Gender...";
    _dateOfBirth.text = "Getting Date Of Birth...";
    _homeAddress.text = "Getting Home Address...";
    _schoolAddress.text = "Getting Permanent Address...";
    _mobileNumber.text = "Getting Mobile Number...";
    _postalCode.text = "Getting Postal Code...";

    // _stateName.text = "Getting State...";
    // _regionName.text = "Getting Region...";
    // _districtName.text = "Getting District...";
    // _anchalName.text = "Getting Anchal...";
    // _sankulName.text = "Getting Sankul...";
    // _clusterName.text = "Getting Cluster...";
    // _subClusterName.text = "Getting Sub-Cluster...";
    // _villageName.text = "Getting Village...";
    // _eduQualification.text = "Getting Edu Qualification...";

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('userPersonalInformation')
          .snapshots(),
      builder: (ctx, AsyncSnapshot userInfoDetail) {
        if (userInfoDetail.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else {
          return Container(
            margin: EdgeInsets.only(
              left: screenWidth * 0.0125,
              right: screenWidth * 0.0125,
              top: screenHeight * 0.00625,
              bottom: screenHeight * 0.025,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 10,
              child: ListView(
                children: <Widget>[
                  imageContainer(
                      context, userMapping["profilePic_Url"] as String),
                  SizedBox(
                    height: useableHeight * 0.004,
                  ),
                  TextFildContainer(
                    context,
                    "First Name  \n???????????? ?????????",
                    _firstName,
                    'first_Name',
                    _isFirstNameSet,
                  ),
                  TextFildContainer(
                    context,
                    "Last Name  \n???????????????",
                    _lastName,
                    'last_Name',
                    _isLastNameSet,
                  ),
                  TextFildContainer(
                    context,
                    "Age/?????????  ",
                    _age,
                    'age',
                    _isAgeSet,
                  ),
                  TextFildContainer(
                    context,
                    "Gender/????????????  ",
                    _gender,
                    'gender',
                    _isGenderSet,
                  ),
                  TextFildContainer(
                    context,
                    "Date Of Birth  \n???????????? ?????? ???????????????",
                    _dateOfBirth,
                    'date_Of_Birth',
                    _isDateTimeSet,
                  ),
                  TextFildContainer(
                    context,
                    "Edu Qfy  \n???????????????????????? ?????????????????????",
                    _eduQualification,
                    'education_Qualification',
                    _isEducationQualificationSet,
                  ),
                  TextFildContainer(
                    context,
                    "Mobile No  \n?????????????????? ????????????",
                    _mobileNumber,
                    'mobile_Number',
                    _isMobileNumberSet,
                  ),
                  TextFildContainer(
                    context,
                    "Home Address \n?????? ?????? ?????????",
                    _homeAddress,
                    'home_Address',
                    _isHomeAddressSet,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: _isAcharyaInfo
                        ? TextFildContainer(
                            context,
                            "School Address \n??????????????? ?????? ?????????",
                            _schoolAddress,
                            'school_Address',
                            _isSchoolAddressSet,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                  TextFildContainer(
                    context,
                    "Pin Code  \n????????? ?????????",
                    _postalCode,
                    'postal_Code',
                    _isPostalCodeSet,
                  ),
                  SizedBox(
                    height: useableHeight * 0.05,
                  ),
                  Container(
                    decoration: new BoxDecoration(
                        color: Color.fromARGB(255, 240, 184, 184)),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.0125,
                    ),
                    child: Text(
                      "Address Information Details\n????????? ????????????????????? ???????????????",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFildContainer(
                    context,
                    "Designation Type  \n??????????????? ??????????????????",
                    _designationType,
                    'designation_Type',
                    _isDesignatoinTypeSet,
                  ),
                  TextFildContainer(
                    context,
                    subDesignationType,
                    _designationRoleType,
                    'designation_RoleType',
                    _isDesignationRoleTypeSet,
                  ),
                  TextFildContainer(
                    context,
                    "Davitya Level  \n?????????????????? ????????????",
                    _dayitvaType,
                    'dayitva_Type',
                    _isDayitvaTypeSet,
                  ),
                  SizedBox(
                    height: useableHeight * 0.025,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: _isPrabhagVisible
                        ? TextFildContainer(
                            context,
                            "Prabhag  \n??????????????????",
                            _PrabagLocationType,
                            'prabhag_LevelType',
                            _isPrabagLocationTypeSet,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: _isSambhagVisible
                        ? TextFildContainer(
                            context,
                            "Sambhag  \n????????????",
                            _SambhagLocationType,
                            'sambhag_LevelType',
                            _isSambhagLocationTypeSet,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: _isBhagVisible
                        ? TextFildContainer(
                            context,
                            "Bhag  \n?????????",
                            _BhagLocationType,
                            'bhag_LevelType',
                            _isBhagLocationTypeSet,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: _isAnchalVisible
                        ? TextFildContainer(
                            context,
                            "Anchal  \n????????????",
                            _AnchalLocationType,
                            'anchal_LevelType',
                            _isAnchalLocationTypeSet,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: _isClusterVisible
                        ? TextFildContainer(
                            context,
                            "Cluster  \n????????????",
                            _ClusterLocationType,
                            'cluster_LevelType',
                            _isClusterLocationTypeSet,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: _isSanchVisible
                        ? TextFildContainer(
                            context,
                            "Sanch  \n????????????",
                            _SanchLocationType,
                            'sanch_LevelType',
                            _isSanchLocationTypeSet,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: _isUpSanchVisible
                        ? TextFildContainer(
                            context,
                            "Up-Sanch  \n??????-????????????",
                            _UpSanchLocationType,
                            'upSanch_LevelType',
                            _isUpSanchLocationTypeSet,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: _isVillageVissible
                        ? TextFildContainer(
                            context,
                            "Village  \n????????????",
                            _VillageLocationType,
                            'village_LevelType',
                            _isVillageLocationTypeSet,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                  SizedBox(
                    height: useableHeight * 0.05,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.01,
                      vertical: screenHeight * 0.0025,
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
          );
        }
      },
    );
  }

  Widget imageContainer(BuildContext context, String imgUrl) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    var topInsets = MediaQuery.of(context).viewInsets.top;
    var bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    var useableHeight = screenHeight - topInsets - bottomInsets;

    final defaultImg = 'assets/images/uProfile.png';
    bool isImageAvailable = false;
    if (imgUrl.length > 0) isImageAvailable = true;

    return Container(
      height: useableHeight * 0.3,
      padding: EdgeInsets.symmetric(
        vertical: useableHeight * 0.010,
        horizontal: screenWidth * 0.015,
      ),
      margin: EdgeInsets.symmetric(
        vertical: useableHeight * 0.0025,
      ),
      child: Card(
        elevation: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade100,
          ),
          padding: EdgeInsets.symmetric(vertical: useableHeight * 0.01),
          alignment: Alignment.center,
          child: CircleAvatar(
            radius: screenWidth * 0.4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth * 0.4),
              child: ClipOval(
                child: isImageAvailable
                    ? Image.network(imgUrl)
                    : Image.asset(defaultImg),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget TextFildContainer(
    BuildContext context,
    String titleText,
    TextEditingController textCtr,
    String infoType,
    bool isSet,
  ) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    var topInsets = MediaQuery.of(context).viewInsets.top;
    var bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    var useableHeight = screenHeight - topInsets - bottomInsets;

    // getUserInformation(context, infoType, textCtr, isSet);
    setUserInfo(context, infoType, textCtr);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.015,
      ),
      child: Card(
        elevation: 13,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.025,
            vertical: useableHeight * 0.015,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "${titleText}: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: screenWidth * 0.001,
              ),
              Flexible(
                child: new Text('${textCtr.text}'),
              ),
              SizedBox(
                width: screenWidth * 0.001,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setUserInfo(
      BuildContext context, String infoType, TextEditingController textCtr) {
    var userInfoDetails = Provider.of<UserDetails>(context);
    Map<String, String> userMapping =
        userInfoDetails.getUserPersonalInformation();

    if (userMapping[infoType] != Null) {
      textCtr.text = userMapping[infoType] as String;
    }
  }
}
