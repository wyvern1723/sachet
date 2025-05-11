import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CaptchaRecognizer {
  Interpreter? _interpreter;
  final String modelPath = 'assets/models/captcha_model.tflite';
  // 验证码图片中可能出现的字符串（一共10个）。顺序不能动！！！
  final List<String> charSet = const [
    '1',
    '2',
    '3',
    'b',
    'c',
    'm',
    'n',
    'v',
    'x',
    'z'
  ];

  // --- Model Input Parameters (ADJUST THESE) ---
  final int modelInputHeight = 20;
  final int modelInputWidth = 20;
  // true if model expects float32 [0,1], false if uint8 [0,255]
  final bool isFloatInput = true;
  // If model expects character as white (1.0 or 255) and background as black (0.0 or 0)
  final bool charIsWhite = true;

  // --- Binarization Threshold (ADJUST THIS) ---
  // This value (0-255) separates foreground (char) from background.
  // It might need tuning based on your images.
  final int binaryThreshold = 128;

  // 加载 TFLite 模型
  Future<void> loadModel() async {
    try {
      if (_interpreter != null) {
        if (kDebugMode) {
          print('模型 ($modelPath) 已加载');
        }
      } else {
        _interpreter = await Interpreter.fromAsset(modelPath);
        if (kDebugMode) {
          print('模型 ($modelPath) 加载成功');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('模型 ($modelPath) 加载失败: $e');
      }
      throw Exception(e);
    }
  }

  /// Preprocesses a single character image for the TFLite model.
  ///
  /// Steps:
  /// 1. Resize to model input dimensions (e.g., 20x20).
  /// 2. Convert to grayscale.
  /// 3. Binarize the image.
  /// 4. Convert to the format expected by the model (e.g., 4D float tensor).
  dynamic _preprocessImage(img.Image charImage) {
    // 1. Resize
    img.Image resizedImage = img.copyResize(
      charImage,
      width: modelInputWidth,
      height: modelInputHeight,
      interpolation: img.Interpolation.average, // Or bilinear, nearest
    );

    // 2. Convert to Grayscale (even if it might seem binarized already)
    // This ensures a single channel for pixel access.
    img.Image grayscaleImage = img.grayscale(resizedImage);

    // 3. Binarize
    for (int y = 0; y < grayscaleImage.height; y++) {
      for (int x = 0; x < grayscaleImage.width; x++) {
        final pixel = grayscaleImage.getPixel(x, y);
        // For grayscale, r,g,b are the same. We use luminance.
        final luminance = pixel.r; // or pixel.g or pixel.b or pixel.luminance

        if (charIsWhite) {
          // Character is white, background is black
          if (luminance > binaryThreshold) {
            grayscaleImage.setPixelRgba(x, y, 255, 255, 255, 255); // White
          } else {
            grayscaleImage.setPixelRgba(x, y, 0, 0, 0, 255); // Black
          }
        } else {
          // Character is black, background is white
          if (luminance > binaryThreshold) {
            grayscaleImage.setPixelRgba(x, y, 0, 0, 0, 255); // Black
          } else {
            grayscaleImage.setPixelRgba(x, y, 255, 255, 255, 255); // White
          }
        }
      }
    }

    // 4. Convert to 4D Tensor [1, height, width, 1]
    if (isFloatInput) {
      var inputTensor = List.generate(
        1,
        (b) => List.generate(
          modelInputHeight,
          (h) => List.generate(
            modelInputWidth,
            (w) => List.generate(1, (c) {
              final pixelValue =
                  grayscaleImage.getPixel(w, h).r; // r,g,b are same
              // Normalize to [0,1]
              // If char is white (255 becomes 1.0), bg is black (0 becomes 0.0)
              // If char is black (0 becomes 1.0), bg is white (255 becomes 0.0)
              // This depends on what the model was trained on.
              // Assuming model expects higher value for the character.
              return (charIsWhite
                  ? (pixelValue / 255.0)
                  : (1.0 - (pixelValue / 255.0)));
            }),
          ),
        ),
      );
      return inputTensor;
    } else {
      // UINT8 input
      var inputTensor = List.generate(
        1,
        (b) => List.generate(
          modelInputHeight,
          (h) => List.generate(
            modelInputWidth,
            (w) => List.generate(1, (c) {
              final pixelValue = grayscaleImage.getPixel(w, h).r;
              // if charIsWhite, model expects 255 for char, 0 for bg
              // if !charIsWhite, model expects 0 for char, 255 for bg
              return (charIsWhite ? pixelValue : (255 - pixelValue));
            }),
          ),
        ),
      );
      return inputTensor;
    }
  }

  Future<String> recognizeCharsInImage(Uint8List imageBytes) async {
    if (_interpreter == null) {
      await loadModel();
    }

    if (_interpreter == null) {
      throw Exception("Error: Model not loaded");
    }

    // final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? fullImage = img.decodeImage(imageBytes);

    if (fullImage == null) {
      throw Exception("Error: Could not decode image");
    }

    // Verify image dimensions (optional, but good for debugging)
    if (fullImage.width != 62 || fullImage.height != 22) {
      if (kDebugMode) {
        print(
            "Warning: Image dimensions are ${fullImage.width}x${fullImage.height}, expected 62x22. Cropping might be inaccurate.");
      }
    }

    final List<List<int>> charPositions = [
      [3, 1, 10, 20], // x, y, width, height
      [12, 1, 10, 20],
      [23, 1, 10, 20],
      [33, 1, 20, 20],
    ];

    String recognizedString = "";

    for (var pos in charPositions) {
      final int x = pos[0];
      final int y = pos[1];
      final int w = pos[2];
      final int h = pos[3];

      // Safety check for crop bounds
      if (x < 0 ||
          y < 0 ||
          x + w > fullImage.width ||
          y + h > fullImage.height) {
        if (kDebugMode) {
          print(
              "Error: Crop position [$x, $y, $w, $h] is out of bounds for image size [${fullImage.width}, ${fullImage.height}]. Skipping.");
        }
        recognizedString += "?"; // Placeholder for error
        continue;
      }

      // 1. Crop the character
      final img.Image charImage = img.copyCrop(
        fullImage,
        x: x,
        y: y,
        width: w,
        height: h,
      );

      // 2. Preprocess the character image
      final dynamic inputData = _preprocessImage(charImage);

      // 3. Prepare output buffer
      // Assuming output is [1, charSet.length]
      var outputData =
          List.filled(1 * charSet.length, 0.0).reshape([1, charSet.length]);

      // 4. Run inference
      try {
        _interpreter!.run(inputData, outputData);
      } catch (e) {
        if (kDebugMode) {
          print("Error during TFLite inference for a character: $e");
        }
        recognizedString += "!"; // Placeholder for inference error
        continue;
      }

      // 5. Postprocess: Get the character with the highest probability
      List<double> probabilities = List<double>.from(outputData[0]);
      int bestIndex = 0;
      double maxProb = 0.0;
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          bestIndex = i;
        }
      }
      if (bestIndex < charSet.length) {
        recognizedString += charSet[bestIndex];
      } else {
        recognizedString +=
            "?"; // Should not happen if charSet matches model output
      }
    }
    return recognizedString;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
