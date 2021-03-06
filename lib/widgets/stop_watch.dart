import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as sysPath;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';

class StopWatch extends StatefulWidget {
  final Function(bool, int) classDurationTime;

  StopWatch(
    this.classDurationTime,
  );

  @override
  State<StopWatch> createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  bool isSDbtnActive = false;
  Future<void> _checkNullStopWatch(BuildContext context) async {
    int hrs = countdownDuration.inHours;
    int min = countdownDuration.inMinutes;

    if (hrs <= 0 && min <= 0) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('InValid Duration!'),
          content: Text('Please enter a Valid Duration of Class...'),
          actions: <Widget>[
            RaisedButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop(false);
    }
  }

  Future<void> selctionOfClassDuration(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Select Class Duration'),
        content: buildTimePicker(context),
        actions: <Widget>[
          RaisedButton(
            child: Text('Ok'),
            onPressed: () {
              // Navigator.of(ctx).pop(false);
              _checkNullStopWatch(context);

              // setState(() {
              //   int minCnt = ((countdownDuration.inHours*60)+countdownDuration.inMinutes);
              //   Future.delayed(Duration(minutes: minCnt), () {
              //     setState(() {
              //       widget.classDurationTime(true, minCnt);
              //     });
              //   });
              // });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _checkForResetTimer(BuildContext context, String titleText,
      String contextText, VoidCallback stopTimerFunc) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${titleText}'),
        content: Text('${contextText}'),
        actions: <Widget>[
          RaisedButton(
            child: Text('NO'),
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
          ),
          RaisedButton(
            child: Text('Yes'),
            onPressed: () {
              stopTimerFunc();
              Navigator.of(ctx).pop(false);

              isSDbtnActive = false;
            },
          ),
        ],
      ),
    );
  }

  Duration userDuration = Duration();

  static var countdownDuration = Duration(
    hours: 0,
    minutes: 1,
    seconds: 0,
  );

  Duration duration = Duration();
  Timer? timer;

  bool isCountDown = true;

  @override
  void initState() {
    super.initState();

    // startTimer();
    reset();
  }

  void reset() {
    if (isCountDown) {
      setState(() => duration = countdownDuration);
    } else {
      setState(() => duration = Duration());
    }
  }

  void addTime() {
    final addSeconds = isCountDown ? -1 : 1;

    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }

    setState(() => timer?.cancel());
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child: buildTime(context),
    );
  }

  Widget buildTime(BuildContext ctx) {
    var screenHeight = MediaQuery.of(ctx).size.height;
    var screenWidtht = MediaQuery.of(ctx).size.width;

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.025,
        ),
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('Select Duration'),
              onPressed: !isSDbtnActive
                  ? () {
                      selctionOfClassDuration(ctx);
                    }
                  : null,
            ),
            Container(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.02,
              ),
              child: Text(
                'Time Left:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildTimeCard(
                  time: hours,
                  header: 'Hrs',
                  ctx: ctx,
                ),
                SizedBox(
                  width: screenWidtht * 0.03,
                ),
                buildTimeCard(
                  time: minutes,
                  header: 'Min',
                  ctx: ctx,
                ),
                SizedBox(
                  width: screenWidtht * 0.03,
                ),
                buildTimeCard(
                  time: seconds,
                  header: 'Sec',
                  ctx: ctx,
                ),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            buildButtons(ctx),
          ],
        ),
      ),
    );
  }

  Widget buildButtons(BuildContext ctx) {
    var screenHeight = MediaQuery.of(ctx).size.height;
    var screenWidth = MediaQuery.of(ctx).size.width;

    final isRunning = timer == null ? false : timer!.isActive;
    final isCompleted = duration.inSeconds == 0;

    return isRunning
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text(
                  'STOP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  if (isRunning) {
                    stopTimer(resets: false);

                    setState(() {
                      int minCnt = double.infinity as int;
                      Future.delayed(Duration(minutes: minCnt), () {
                        setState(() {
                          widget.classDurationTime(true, minCnt);
                        });
                      });
                    });
                  }
                },
              ),
              SizedBox(
                width: screenWidth * 0.01,
              ),
              RaisedButton(
                child: Text(
                  'RESET',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  _checkForResetTimer(ctx, 'Request For Reset!',
                      'Are your sure you want to Reset Timer?', stopTimer);
                  // stopTimer();

                  // setState(() {
                  //   int minCnt = double.infinity as int;
                  //   Future.delayed(Duration(minutes: minCnt), () {
                  //     setState(() {
                  //       widget.classDurationTime(true, minCnt);
                  //     });
                  //   });
                  // });
                },
              ),
            ],
          )
        : RaisedButton(
            child: Text(
              'Start Timer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Colors.black,
            textColor: Colors.white,
            onPressed: () {
              startTimer();

              setState(() {
                isSDbtnActive = true;
                int minCnt = ((countdownDuration.inHours * 60) +
                    countdownDuration.inMinutes);
                Future.delayed(Duration(minutes: minCnt), () {
                  setState(() {
                    widget.classDurationTime(true, minCnt);
                  });
                });
              });
            },
          );
  }

  Widget buildTimeCard({
    required String time,
    required String header,
    required BuildContext ctx,
  }) {
    var screenHeight = MediaQuery.of(ctx).size.height;
    var screenWidth = MediaQuery.of(ctx).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.005,
            horizontal: screenWidth * 0.01,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '${time}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: screenHeight * 0.07,
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.008,
        ),
        Text(header),
      ],
    );
  }

  Widget buildTimePicker(BuildContext ctx) {
    var screenHeight = MediaQuery.of(ctx).size.height;
    var screenWidth = MediaQuery.of(ctx).size.width;

    return SizedBox(
      height: screenHeight * 0.4,
      width: screenWidth,
      child: CupertinoTimerPicker(
        initialTimerDuration: countdownDuration,
        mode: CupertinoTimerPickerMode.hms,
        minuteInterval: 1,
        secondInterval: 30,
        onTimerDurationChanged: (currDuration) => setState(() {
          countdownDuration = currDuration;
          reset();
        }),
      ),
    );
  }
}
