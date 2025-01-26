import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marksheet_model.dart';
import '../services/marks_evaluation_service.dart';

class TeacherMarksheetScreen extends StatefulWidget {
  @override
  _TeacherMarksheetScreenState createState() => _TeacherMarksheetScreenState();
}

class _TeacherMarksheetScreenState extends State<TeacherMarksheetScreen> {
  bool _isEvaluating = false;
  bool _isEditing = false;
  bool _isEditingMarks = false;
  String _aiOverview = '';
  double _studentScore = 0;
  double _totalMarks = 0;
  PlatformFile? _uploadedAnswerSheet;
  PlatformFile? _uploadedQuestionPaper;
  final TextEditingController _markingSchemeController = TextEditingController();
  final TextEditingController _evaluationController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _studentScoreController = TextEditingController();
  final TextEditingController _totalMarksController = TextEditingController();

  Future<void> _evaluateMarksheet() async {
    setState(() {
      _isEvaluating = true;
      _aiOverview = '';
      _studentScore = 0;
      _totalMarks = 0;
    });

    try {
      if (_markingSchemeController.text.isEmpty) {
        setState(() {
          _aiOverview = 'Please provide a marking scheme.';
        });
        return;
      }

      if (_uploadedQuestionPaper == null || _uploadedAnswerSheet == null) {
        setState(() {
          _aiOverview = 'Please upload both the question paper and answer sheet.';
        });
        return;
      }

      final questionPaperContent = await MarksEvaluationService.processFile(_uploadedQuestionPaper!);
      final answerSheetContent = await MarksEvaluationService.processFile(_uploadedAnswerSheet!);

      final prompt = '''
Marking Scheme:
${_markingSchemeController.text}

Question Paper:
$questionPaperContent

Answer Sheet:
$answerSheetContent

Evaluate the answer sheet strictly according to the instructions provided in the marking scheme and the questions in the question paper.
Highlight areas where the student is struggling and provide feedback based on the marking scheme and question paper.
Also calculate and provide:
1. Total marks available in the paper
2. Total marks scored by the student
Format these at the start of your response as: "MARKS: [scored]/[total]"
Then continue with the detailed evaluation.
''';

      final response = await MarksEvaluationService.model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? 'No evaluation available.';
      
      // Extract marks from response
      if (responseText.contains('MARKS:')) {
        final marksMatch = RegExp(r'MARKS:\s*(\d+)/(\d+)').firstMatch(responseText);
        if (marksMatch != null) {
          _studentScore = double.parse(marksMatch.group(1)!);
          _totalMarks = double.parse(marksMatch.group(2)!);
          _scoreController.text = '${_studentScore.toStringAsFixed(1)}/${_totalMarks.toStringAsFixed(1)}';
          _studentScoreController.text = _studentScore.toStringAsFixed(1);
          _totalMarksController.text = _totalMarks.toStringAsFixed(1);
        }
      }

      setState(() {
        _aiOverview = responseText.replaceFirst(RegExp(r'MARKS:.*\n'), '').trim();
        _evaluationController.text = _aiOverview;
      });
    } catch (e) {
      setState(() {
        _aiOverview = 'Failed to evaluate marksheet. Please try again.';
      });
    } finally {
      setState(() {
        _isEvaluating = false;
      });
    }
  }

  Future<void> _publishResults() async {
    try {
      // TODO: Implement backend integration
      // Send evaluation data to backend
      final evaluationData = {
        'score': _studentScore,
        'totalMarks': _totalMarks,
        'feedback': _evaluationController.text,
        // Add other necessary fields
      };
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Results published successfully!'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish results. Please try again.'))
      );
    }
  }

  Future<void> _pickFile(bool isQuestionPaper) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        if (isQuestionPaper) {
          _uploadedQuestionPaper = result.files.first;
        } else {
          _uploadedAnswerSheet = result.files.first;
        }
      });
    }
  }

  Widget _buildUploadSection(String title, bool isQuestionPaper, PlatformFile? file) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade100, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _pickFile(isQuestionPaper),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue.shade700),
                      SizedBox(height: 8),
                      Text(
                        file?.name ?? 'Click to upload PDF/Image',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Teacher Marksheet',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue.shade900,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(constraints.maxWidth > 600 ? 32 : 16),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_aiOverview.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'AI Evaluation Results',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                if (_totalMarks > 0)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          _isEditingMarks ? Icons.save : Icons.edit_note,
                                          color: Colors.blue.shade700,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isEditingMarks = !_isEditingMarks;
                                            if (!_isEditingMarks) {
                                              // Update scores when saving
                                              _studentScore = double.tryParse(_studentScoreController.text) ?? _studentScore;
                                              _totalMarks = double.tryParse(_totalMarksController.text) ?? _totalMarks;
                                              _scoreController.text = '${_studentScore.toStringAsFixed(1)}/${_totalMarks.toStringAsFixed(1)}';
                                            }
                                          });
                                        },
                                        tooltip: _isEditingMarks ? 'Save Marks' : 'Edit Marks',
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isEditing ? Icons.save : Icons.edit,
                                          color: Colors.blue.shade700,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isEditing = !_isEditing;
                                            if (!_isEditing) {
                                              _aiOverview = _evaluationController.text;
                                            }
                                          });
                                        },
                                        tooltip: _isEditing ? 'Save Feedback' : 'Edit Feedback',
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                            if (_totalMarks > 0)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: _isEditingMarks
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: TextField(
                                              controller: _studentScoreController,
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade900,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                                constraints: BoxConstraints(maxWidth: 60),
                                              ),
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                          Text(
                                            ' / ',
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                          Flexible(
                                            child: TextField(
                                              controller: _totalMarksController,
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade900,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                                constraints: BoxConstraints(maxWidth: 60),
                                              ),
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Score: ${_studentScore.toStringAsFixed(1)}/${_totalMarks.toStringAsFixed(1)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                              ),
                            SizedBox(height: 16),
                            _isEditing
                                ? TextField(
                                    controller: _evaluationController,
                                    maxLines: null,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      height: 1.6,
                                      color: Colors.grey.shade800,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  )
                                : Text(
                                    _aiOverview,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      height: 1.6,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                            if (_totalMarks > 0 && !_isEditing)
                              Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = true;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade100,
                                        foregroundColor: Colors.blue.shade900,
                                      ),
                                      child: Text('Edit'),
                                    ),
                                    SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: _publishResults,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                      ),
                                      child: Text('Publish'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 32),
                    
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marking Scheme',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _markingSchemeController,
                            decoration: InputDecoration(
                              hintText: 'Enter detailed marking criteria and instructions...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade100),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade400),
                              ),
                              filled: true,
                              fillColor: Colors.blue.shade50.withOpacity(0.3),
                            ),
                            maxLines: 5,
                            style: GoogleFonts.inter(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    _buildUploadSection('Question Paper', true, _uploadedQuestionPaper),
                    SizedBox(height: 24),
                    _buildUploadSection('Answer Sheet', false, _uploadedAnswerSheet),
                    SizedBox(height: 32),

                    Center(
                      child: ElevatedButton(
                        onPressed: _isEvaluating ? null : _evaluateMarksheet,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isEvaluating
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Evaluate with AI',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}