import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:developer' as developer;

import '../../vars.dart';

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);

  HSLColor hslDark;
  if (hsl.saturation == 0) {
    // Preserve grayscale by keeping hue and saturation at zero
    hslDark = HSLColor.fromAHSL(hsl.alpha, 0.0, 0.0, lightness);
  } else {
    hslDark = hsl.withLightness(lightness);
  }

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);

  HSLColor hslLight;
  if (hsl.saturation == 0) {
    // Preserve grayscale by keeping hue and saturation at zero
    hslLight = HSLColor.fromAHSL(hsl.alpha, 0.0, 0.0, lightness);
  } else {
    hslLight = hsl.withLightness(lightness);
  }

  return hslLight.toColor();
}

Color blendColors(Color color1, Color color2, [double percentage = 0.5]) {
  percentage = max(0, min(percentage, 1));
  return Color.fromRGBO(
    (color1.red * percentage + color2.red * (1 - percentage)) ~/ 1,
    (color1.green * percentage + color2.green * (1 - percentage)) ~/ 1,
    (color1.blue * percentage + color2.blue * (1 - percentage)) ~/ 1,
    1, // Assuming you want full opacity
  );
}

///Values range: 0.0 - 1.0
Color adjustColor(Color color, {required double saturationFactor, required double brightnessFactor}) {
  HSVColor hsvColor = HSVColor.fromColor(color);

  double newSaturation = (hsvColor.saturation * saturationFactor).clamp(0.0, 1.0);
  double newBrightness = (hsvColor.value * brightnessFactor).clamp(0.0, 1.0);

  HSVColor adjustedColor = hsvColor.withSaturation(newSaturation).withValue(newBrightness);

  return adjustedColor.toColor();
}

/// Estimates the width of the text and cuts it if necessary to fit within the specified maximum width.
///
/// The `text` parameter represents the input text.
/// The `maxWidth` parameter specifies the maximum width allowed for the text.
/// The `textStyle` parameter defines the style of the text (default is an empty [TextStyle]).
/// The `minDisplayWidth` parameter sets the minimum display width (default is -1).
///
/// Returns the modified text that fits within the maximum width, or an empty string if the minimum display width is greater than the maximum width.
String estimateWidthAndCutText(String text, double maxWidth, [TextStyle textStyle = const TextStyle(), double minDisplayWidth = -1]) {
  if (maxWidth <= 0) maxWidth = 10;
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: textStyle),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();

  if (minDisplayWidth != -1 && minDisplayWidth > maxWidth) return "";

  // If the text fits within the max width, return it as is.
  if (textPainter.width <= maxWidth) {
    return text;
  }

  // Calculate the cutoff point while leaving room for ellipsis and last segment after the last period.
  String suffix = '';
  int lastPeriodIndex = text.lastIndexOf('.');
  if (lastPeriodIndex != -1 && lastPeriodIndex != text.length - 1) {
    suffix = text.substring(lastPeriodIndex - 2); // Capture the last two chars before the period and everything after
  }

  // Start reducing the text size until it fits with the ellipsis and suffix.
  String result = text;
  while (result.isNotEmpty) {
    result = text.substring(0, result.length - 1);
    textPainter.text = TextSpan(text: '$result...$suffix', style: textStyle);
    textPainter.layout();

    if (textPainter.width <= maxWidth) {
      return '$result...$suffix';
    }
  }

  return '...'; // Fallback if no sufficient space even for the first character plus ellipsis.
}

/// Estimates the width of the text and divides it into two parts if necessary to fit within the specified maximum width.
///
/// The `text` parameter represents the input text.
/// The `maxWidth` parameter specifies the maximum width allowed for the text.
/// The `textStyle` parameter defines the style of the text.
///
/// Returns a tuple containing the modified text that fits within the maximum width and the remaining text that couldn't fit.

(String, String) estimateAndDivideText(String text, double maxWidth, TextStyle textStyle) {
  text = text.trim();
  if (maxWidth <= 0) maxWidth = 10;
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: textStyle),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();

  // If the text fits within the max width, return it as is.
  if (textPainter.width <= maxWidth) return (text, '');

  // Start reducing the text size while preferring to cut at spaces.
  int cutIndex = text.length;
  while (cutIndex > 0) {
    int spaceIndex = text.trim().lastIndexOf(' ', cutIndex - 1);
    if (spaceIndex == -1) spaceIndex = cutIndex - 1;

    String result = text.substring(0, spaceIndex).trim();
    textPainter.text = TextSpan(text: result, style: textStyle);
    textPainter.layout();

    if (textPainter.width <= maxWidth) return (result, text.substring(result.length).trim());

    cutIndex = spaceIndex;
  }
  // Fallback if no sufficient space even for the first character.
  return ('', text);
}

/// Calculates the size of the text based on the specified style.
///
/// The `text` parameter represents the input text.
/// The `style` parameter defines the style of the text.
///
/// Returns the size of the text.
Size calculateTextSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout(minWidth: 0, maxWidth: double.infinity);

  return textPainter.size;
}

bool logOG = false;

void log(final dynamic msg, [final Color color = Colors.white, final Color bgColor = Colors.transparent, Object? error]) {
  if (!kDebugMode) return;
  String escapeCode = getColorEscapeCode(color);
  String bgEscapeCode = getColorEscapeCodeBg(bgColor);
  //developer.log('\x1B[2J$escapeCode$bgEscapeCode${msg.toString()}', error: error);
  developer.log('$escapeCode$bgEscapeCode${msg.toString()}', error: error);
}

/// Logs an info message with the specified [msg] and sets the text color to Very Light Blue.
void logInfo(final dynamic msg) => log(msg, const Color.fromARGB(255, 187, 254, 255));

/// Logs a success message with the specified [msg] and sets the text color to Green.
void logSuccess(final dynamic msg) => log(msg, Colors.green);

/// Logs an error message with the specified [msg] and sets the text color to Red.
void logErr(final dynamic msg, [Object? error]) {
  logger.e(msg, error: error, stackTrace: StackTrace.current, time: now);
  // ignore: avoid_print
  if (!kDebugMode) print(msg);
  //log(msg, Colors.red, Colors.transparent, error);
}

/// Logs a warning message with the specified [msg] and sets the text color to Orange.
void logWarn(final dynamic msg) => log(msg, Colors.amber);

/// Returns the escape code for the specified text color.
///
/// The `color` parameter is the text color.
/// Returns the escape code as a string.
String getColorEscapeCode(Color color) {
  int r = color.red;
  int g = color.green;
  int b = color.blue;
  return '\x1B[38;2;$r;$g;${b}m';
}

/// Returns the escape code for the specified background color.
///
/// The `color` parameter is the background color.
/// Returns the escape code as a string.
String getColorEscapeCodeBg(Color color) {
  if (color == Colors.transparent) return '\x1B[49m'; // Reset background color (transparent)
  int r = color.red;
  int g = color.green;
  int b = color.blue;
  return '\x1B[48;2;$r;$g;${b}m';
}

Logger logger = Logger();

/// Logs multiple messages with optional text colors and background colors.
///
/// The `messages` parameter is a list of lists, where each inner list contains the String `message`,
/// the Color `text color` (optional, defaults to [Colors.white]),
/// and the Color `background color` (optional, defaults to [Colors.transparent]).
void logMulti(List<List<dynamic>> messages) {
  if (!kDebugMode) return;
  String logMessage = '';
  for (var innerList in messages) {
    String msg = innerList[0];
    Color color = innerList.length > 1 ? innerList[1] : Colors.white;
    Color bgColor = innerList.length > 2 ? innerList[2] : Colors.transparent;

    String escapeCode = getColorEscapeCode(color);
    String bgEscapeCode = getColorEscapeCodeBg(bgColor);
    logMessage += '$escapeCode$bgEscapeCode$msg';
  }
  developer.log(logMessage);
}
