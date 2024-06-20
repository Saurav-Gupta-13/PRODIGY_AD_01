import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../controller/calculate_controller.dart';
import '../controller/theme_controller.dart';
import '../utils/colors.dart';
import '../widget/button.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Timer? _debounceTimer;
  Set<String> _processedCommands = {};

  final List<String> buttons = [
    "C", "DEL", "%", "/",
    "9", "8", "7", "x",
    "6", "5", "4", "-",
    "3", "2", "1", "+",
    "0", ".", "ANS", "=",
  ];

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isVoiceAssistantEnabled = false;
  String _lastWords = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onError: (val) {
        Fluttertoast.showToast(msg: 'Error initializing speech: $val');
        print('Error initializing speech: $val');
      },
      onStatus: (val) {
        Fluttertoast.showToast(msg: 'Speech status: $val');
        print('Speech status: $val');
      },
    );
    if (available) {
      Fluttertoast.showToast(msg: 'Speech recognition initialized');
    } else {
      Fluttertoast.showToast(msg: 'Speech initialization failed');
      print('Speech initialization failed');
    }
  }

  void _listen(CalculateController controller) async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _isVoiceAssistantEnabled = true; // Enable voice assistant
        });
        _speech.listen(
          onResult: (val) {
            setState(() {
              _lastWords = val.recognizedWords.toLowerCase().trim();
            });

            // Check if the command has already been processed
            if (!_processedCommands.contains(_lastWords)) {
              _processedCommands.add(_lastWords);

              // Handle the command here
              controller.onVoiceCommand(_lastWords);
            }
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _isVoiceAssistantEnabled = false; // Disable voice assistant
      });
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<CalculateController>();
    var themeController = Get.find<ThemeController>();

    return GetBuilder<ThemeController>(builder: (context) {
      return Scaffold(
        backgroundColor: themeController.isDark
            ? DarkColors.scaffoldBgColor
            : LightColors.scaffoldBgColor,
        body: Column(
          children: [
            Expanded(
              child: outPutSection(themeController, controller),
            ),
            inPutSection(themeController, controller),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                _listen(controller);
              },
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              tooltip: 'Voice Assistant',
            ),
          ],
        ),
      );
    });
  }

  Widget inPutSection(
      ThemeController themeController, CalculateController controller) {
    return GetBuilder<CalculateController>(builder: (controller) {
      return Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: themeController.isDark
                ? DarkColors.sheetBgColor
                : LightColors.sheetBgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: buttons.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
            itemBuilder: (context, index) {
              return CustomAppButton(
                buttonTapped: () {
                  if (_isVoiceAssistantEnabled) {
                    Fluttertoast.showToast(msg: 'Manual typing is disabled.');
                  } else {
                    // Ensure only operators and special buttons can be tapped
                    if (index == 0) {
                      controller.clearInputAndOutput();
                    } else if (index == 1) {
                      controller.deleteBtnAction();
                    } else if (index == 19) {
                      controller.equalPressed();
                    } else {
                      // Handle numbers and other operators
                      controller.onBtnTapped(buttons, index);
                    }
                  }
                },
                color: getButtonColor(index, themeController),
                textColor: getButtonTextColor(index, themeController),
                text: buttons[index],
              );
            },
          ),
        ),
      );
    });
  }

  Color getButtonColor(int index, ThemeController themeController) {
    if (index == 0 || index == 1 || index == 19) {
      return themeController.isDark
          ? DarkColors.leftOperatorColor
          : LightColors.leftOperatorColor;
    } else {
      return themeController.isDark
          ? DarkColors.btnBgColor
          : LightColors.btnBgColor;
    }
  }

  Color getButtonTextColor(int index, ThemeController themeController) {
    if (index == 0 || index == 1 || index == 19) {
      return themeController.isDark
          ? DarkColors.btnBgColor
          : LightColors.btnBgColor;
    } else {
      return isOperator(buttons[index])
          ? Colors.white
          : themeController.isDark
              ? Colors.white
              : Colors.black;
    }
  }

  Widget outPutSection(
      ThemeController themeController, CalculateController controller) {
    return GetBuilder<CalculateController>(builder: (controller) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: AdvancedSwitch(
                controller: themeController.switcherController,
                activeImage: const AssetImage('assets/day_sky.png'),
                inactiveImage: const AssetImage('assets/night_sky.jpg'),
                activeColor: Colors.green,
                inactiveColor: Colors.grey,
                activeChild: Text(
                  'Day',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                inactiveChild: Text(
                  'Night',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(1000)),
                width: 100.0,
                height: 45.0,
                enabled: true,
                disabledOpacity: 0.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 70),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      controller.userInput,
                      style: TextStyle(
                        color: themeController.isDark ? Colors.white : Colors.black,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      controller.userOutput,
                      style: TextStyle(
                        color: themeController.isDark ? Colors.green : Colors.black,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  bool isOperator(String x) {
    return (x == "%" || x == "/" || x == "x" || x == "-" || x == "+" || x == "=");
  }
}
