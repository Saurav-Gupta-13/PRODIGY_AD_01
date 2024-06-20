import 'package:get/get.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculateController extends GetxController {
  var userInput = "";
  var userOutput = "";

  void equalPressed() {
    try {
      String userInputFC = userInput.replaceAll("x", "*");
      Parser p = Parser();
      Expression exp = p.parse(userInputFC);
      ContextModel ctx = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, ctx);
      userOutput = eval.toString();
    } catch (e) {
      userOutput = "Error";
    }
    update();
  }

  void clearInputAndOutput() {
    userInput = "";
    userOutput = "";
    update();
  }

  void deleteBtnAction() {
    if (userInput.isNotEmpty) {
      userInput = userInput.substring(0, userInput.length - 1);
      update();
    }
  }

  void onBtnTapped(List<String> buttons, int index) {
    userInput += buttons[index];
    update();
  }

  void onVoiceCommand(String command) {
    command = command.toLowerCase().trim();
    print("Received command: $command");

    // Map spoken numbers to their corresponding digits
    Map<String, String> numberMapping = {
      "one": "1",
      "two": "2",
      "three": "3",
      "four": "4",
      "five": "5",
      "six": "6",
      "seven": "7",
      "eight": "8",
      "nine": "9",
      "zero": "0",
    };

    // Replace spoken numbers with digits
    numberMapping.forEach((key, value) {
      command = command.replaceAll(key, value);
    });

    // Further normalization for operators and symbols
    command = command
        .replaceAll("multiply", "*")
        .replaceAll("divide", "/")
        .replaceAll("plus", "+")
        .replaceAll("minus", "-")
        .replaceAll("point", ".")
        .replaceAll("equals", "=");

    // Append the command to userInput and update
    userInput += command.replaceAll(" ", ""); // Remove spaces for better parsing
    update();
  }
}
