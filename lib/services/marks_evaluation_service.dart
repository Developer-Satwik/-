import 'dart:convert'; // For JSON parsing
import 'dart:io'; // For file handling
import 'dart:ui' as ui; // For dart:ui.Image
import 'dart:typed_data'; // For Uint8List and ByteData
import 'package:file_picker/file_picker.dart'; // For file upload functionality
import 'package:image/image.dart'; // For image preprocessing
import 'package:pdf_render/pdf_render.dart'; // For PDF handling
import 'package:google_generative_ai/google_generative_ai.dart'; // For AI functionality
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart'; // For OCR functionality
import 'package:path_provider/path_provider.dart'; // For accessing device storage
import '../results/marksheet_model.dart'; // Import the Marksheet model

class MarksEvaluationService {
  // Hardcoded API key (replace with your actual Gemini API key)
  static const String _apiKey = 'AIzaSyC7EluuQmw1KB-hoVM4s6u3u7-vT7ezc7U';

  // Initialize the Gemini model
  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-pro', // Use the Gemini Pro model
    apiKey: _apiKey,
  );

  // Public getter for the model
  static GenerativeModel get model => _model;

  /// Analyzes a student's marksheet and provides feedback.
  ///
  /// [marksheet]: The list of marksheet entries for the student.
  /// Returns feedback on areas for improvement or an error message.
  static Future<String> analyzeMarksheet(List<Marksheet> marksheet) async {
    try {
      // Convert marksheet to JSON for the prompt
      final marksheetJson = jsonEncode(marksheet.map((m) => m.toMap()).toList());
      final prompt = '''
Analyze the following marksheet and provide detailed feedback on areas for improvement:
$marksheetJson

Provide specific tips and tricks for the student to enhance their performance, including examples and resources.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No feedback available.';
    } catch (e) {
      print('Error analyzing marksheet: $e');
      return 'Failed to analyze the marksheet. Please try again.';
    }
  }

  /// Evaluates a marksheet for the teacher and provides an overview.
  ///
  /// [marksheet]: The list of marksheet entries for the student.
  /// [markingScheme]: The marking scheme text provided by the teacher.
  /// Returns an evaluation of the student's performance or an error message.
  static Future<String> evaluateMarksheetWithMarkingScheme(
      List<Marksheet> marksheet, String markingScheme) async {
    try {
      // Convert marksheet to JSON for the prompt
      final marksheetJson = jsonEncode(marksheet.map((m) => m.toMap()).toList());

      // Use the marking scheme and marksheet data as input for the AI model
      final prompt = '''
Marking Scheme:
$markingScheme

Marksheet Data:
$marksheetJson

Evaluate the marksheet strictly according to the instructions provided in the marking scheme.
Highlight specific areas where the student is struggling, and provide constructive feedback and actionable suggestions based on the marking scheme.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No evaluation available.';
    } catch (e) {
      print('Error evaluating marksheet: $e');
      return 'Failed to evaluate the marksheet. Please try again.';
    }
  }

  /// Preprocesses an image for better OCR accuracy.
  ///
  /// [image]: The image to preprocess.
  /// Returns the preprocessed image.
  static Image _preprocessImage(Image image) {
    // Resize the image to a manageable size
    image = copyResize(image, width: 1200, height: 1600);

    // Convert the image to grayscale
    image = grayscale(image);

    // Apply a binary threshold manually
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = getLuminance(pixel);
        if (luminance < 128) {
          image.setPixel(x, y, ColorFloat16.rgb(0, 0, 0)); // Black
        } else {
          image.setPixel(x, y, ColorFloat16.rgb(255, 255, 255)); // White
        }
      }
    }

    return image;
  }

  /// Converts a PDF file to a list of images.
  ///
  /// [pdfFile]: The PDF file to convert.
  /// Returns a list of images extracted from the PDF.
  static Future<List<Image>> _convertPdfToImages(File pdfFile) async {
    final images = <Image>[];

    // Load the PDF file using pdf_render
    final pdfDoc = await PdfDocument.openFile(pdfFile.path);

    // Convert each page of the PDF to an image
    for (var i = 0; i < pdfDoc.pageCount; i++) {
      final page = await pdfDoc.getPage(i + 1);
      final pageImage = await page.render(width: 1200, height: 1600);

      // Get the dart:ui.Image from the rendered page
      final ui.Image uiImage = await pageImage.createImageDetached();

      // Convert the dart:ui.Image to a format that can be processed by the image package
      final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List imageBytes = byteData.buffer.asUint8List();
        final image = decodeImage(imageBytes);

        if (image != null) {
          images.add(image);
        }
      }

      // Dispose of the dart:ui.Image to free resources
      uiImage.dispose();
    }

    // No need to explicitly close pdfDoc, as it is managed by Dart's garbage collection
    return images;
  }

  /// Processes an uploaded file (PDF or image) and extracts text using OCR.
  ///
  /// [file]: The uploaded file (PDF or image).
  /// Returns the extracted text or an error message.
  static Future<String> processFile(PlatformFile file) async {
    try {
      String extractedText = '';

      if (file.extension == 'pdf') {
        // Handle PDF files
        final pdfFile = File(file.path!);
        final images = await _convertPdfToImages(pdfFile);

        // Extract text from each image using OCR
        for (var image in images) {
          final preprocessedImage = _preprocessImage(image);
          final text = await _performOCR(preprocessedImage);
          extractedText += text + '\n';
        }
      } else {
        // Handle image files
        final imageFile = File(file.path!);
        final image = decodeImage(await imageFile.readAsBytes());

        if (image == null) {
          throw Exception('Failed to decode the image.');
        }

        // Preprocess the image and perform OCR
        final preprocessedImage = _preprocessImage(image);
        extractedText = await _performOCR(preprocessedImage);
      }

      return extractedText;
    } catch (e) {
      print('Error processing file: $e');
      throw Exception('Failed to process the file. Please try again.');
    }
  }

  /// Performs OCR on an image to extract text.
  ///
  /// [image]: The image to process.
  /// Returns the extracted text.
  static Future<String> _performOCR(Image image) async {
    try {
      // Convert the image to a PNG format (Tesseract OCR requires an image file)
      final Uint8List imageBytes = encodePng(image);

      // Save the image to a temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_ocr_image.png');
      await tempFile.writeAsBytes(imageBytes);

      // Path to the tessdata directory
      final tessdataDir = Directory('${await getApplicationDocumentsDirectory()}/tessdata');

      // Perform OCR using FlutterTesseractOcr
      final String extractedText = await FlutterTesseractOcr.extractText(
        tempFile.path,
        language: 'eng+spa+fra', // Use English, Spanish, and French
        args: {
          "tessdata_path": tessdataDir.path, // Pass the tessdata path here
        },
      );

      // Delete the temporary file
      await tempFile.delete();

      return extractedText;
    } catch (e) {
      print('Error performing OCR: $e');
      return 'Failed to extract text from the image.';
    }
  }

  /// Evaluates a marksheet based on an uploaded question paper and answer sheet.
  ///
  /// [questionPaperFile]: The uploaded question paper file (PDF or image).
  /// [answerSheetFile]: The uploaded answer sheet file (PDF or image).
  /// [markingScheme]: The marking scheme text provided by the teacher.
  /// Returns an evaluation of the student's performance or an error message.
  static Future<String> evaluateMarksheetWithQuestionPaperAndAnswerSheet(
      PlatformFile questionPaperFile, PlatformFile answerSheetFile, String markingScheme) async {
    try {
      // Process the question paper
      final questionPaperContent = await processFile(questionPaperFile);

      // Process the answer sheet
      final answerSheetContent = await processFile(answerSheetFile);

      // Use the marking scheme, question paper, and answer sheet content as input for the AI model
      final prompt = '''
Marking Scheme:
$markingScheme

Question Paper:
$questionPaperContent

Answer Sheet:
$answerSheetContent

Evaluate the answer sheet strictly according to the instructions provided in the marking scheme and the questions in the question paper.
Highlight specific areas where the student is struggling, and provide detailed feedback and actionable suggestions based on the marking scheme and question paper.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No evaluation available.';
    } catch (e) {
      print('Error evaluating marksheet with question paper and answer sheet: $e');
      return 'Failed to evaluate the marksheet. Please try again.';
    }
  }
}