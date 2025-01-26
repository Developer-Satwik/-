import 'package:flutter/material.dart';
import 'marksheet_model.dart';
import '../services/marks_evaluation_service.dart';

class StudentResultsScreen extends StatefulWidget {
  final List<Marksheet> marksheet;

  StudentResultsScreen({required this.marksheet});

  @override
  _StudentResultsScreenState createState() => _StudentResultsScreenState();
}

class _StudentResultsScreenState extends State<StudentResultsScreen> {
  String _aiFeedback = '';
  bool _isAnalyzing = false;

  Future<void> _analyzeMarksheet() async {
    setState(() {
      _isAnalyzing = true;
      _aiFeedback = '';
    });

    try {
      final feedback = await MarksEvaluationService.analyzeMarksheet(widget.marksheet);
      setState(() {
        _aiFeedback = feedback;
      });
    } catch (e) {
      setState(() {
        _aiFeedback = 'Failed to analyze marksheet. Please try again.';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          'Academic Performance',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Color(0xFF2C3E50),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Detailed analysis of academic achievements',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 32),
            _buildMarksheetTable(),
            SizedBox(height: 40),

            Center(
              child: Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _analyzeMarksheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Colors.transparent,
                  ),
                  child: _isAnalyzing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.analytics_rounded),
                            SizedBox(width: 12),
                            Text(
                              'Generate AI Insights',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: 32),

            if (_aiFeedback.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2C3E50).withOpacity(0.05),
                      Color(0xFF3498DB).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Color(0xFF2C3E50).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology_rounded,
                          color: Color(0xFF2C3E50),
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'AI Performance Analysis',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      _aiFeedback,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksheetTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Color(0xFF2C3E50),
              ),
              children: [
                _buildHeaderCell('Subject'),
                _buildHeaderCell('Marks Obtained'),
                _buildHeaderCell('Total Marks'),
                _buildHeaderCell('Feedback'),
              ],
            ),
            ...widget.marksheet.map((marksheet) {
              return TableRow(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                children: [
                  _buildDataCell(marksheet.subject),
                  _buildDataCell(marksheet.marksObtained.toString()),
                  _buildDataCell(marksheet.totalMarks.toString()),
                  _buildDataCell(marksheet.feedback),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 15,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }
}