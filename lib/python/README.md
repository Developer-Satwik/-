# Assignment Analysis Service

This service provides AI-powered assignment analysis using LlamaIndex and Google's Gemini API.

## Setup Instructions

1. **Python Environment Setup**
   ```bash
   # Create a virtual environment
   python -m venv venv
   
   # Activate the virtual environment
   # On Windows:
   venv\Scripts\activate
   # On macOS/Linux:
   source venv/bin/activate
   
   # Install dependencies
   pip install -r requirements.txt
   ```

2. **Environment Variables**
   - Create a `.env` file in the `lib/python` directory
   - Add your Google API key:
     ```
     GOOGLE_API_KEY=your_api_key_here
     ```

## Usage

The service can be used through the Flutter app's `AssignmentEvaluationService` class. The service will:
1. Validate inputs
2. Set up the Python environment
3. Run the analysis using LlamaIndex and Gemini
4. Return structured results in JSON format

### Response Format

The analysis results are returned in the following format:
```json
{
    "evaluation": [
        {
            "question_number": 1,
            "points_awarded": 5,
            "max_points": 10,
            "feedback": "Detailed feedback here"
        }
    ],
    "overall_feedback": "General feedback about the entire submission",
    "total_score": 75,
    "max_possible_score": 100,
    "improvement_suggestions": [
        "Suggestion 1",
        "Suggestion 2"
    ]
}
```

## Error Handling

The service includes comprehensive error handling for:
- Missing or invalid inputs
- Python environment setup issues
- API errors
- Invalid responses

All errors are returned in a consistent format:
```json
{
    "status": "failed",
    "error": "Error message here"
}
``` 