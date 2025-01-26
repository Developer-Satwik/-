import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class StudyMaterialsScreen extends StatefulWidget {
  @override
  _StudyMaterialsScreenState createState() => _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends State<StudyMaterialsScreen> {
  String _summary = '';

  void _summarizeTopic(String topic) async {
    String summary = await AIService.summarizeText(topic);
    setState(() {
      _summary = summary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study Materials')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: 'Enter a topic to summarize...'),
              onSubmitted: _summarizeTopic,
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_summary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}