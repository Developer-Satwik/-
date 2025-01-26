from llama_index import Document, VectorStoreIndex
import google.generativeai as genai
import json
import os
from dotenv import load_dotenv
from pathlib import Path

class AssignmentAnalysisService:
    def __init__(self):
        # Load environment variables
        env_path = Path(__file__).parent / '.env'
        load_dotenv(dotenv_path=env_path)
        
        api_key = os.getenv('GOOGLE_API_KEY')
        if not api_key:
            raise ValueError("GOOGLE_API_KEY environment variable is not set")
            
        # Initialize Gemini API
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-pro')

    def analyze_assignment(self, marking_scheme: str, question_sheet: str, answer_sheet: str) -> dict:
        try:
            if not all([marking_scheme, question_sheet, answer_sheet]):
                return {
                    "error": "All inputs (marking scheme, question sheet, answer sheet) are required",
                    "status": "failed"
                }

            # Create documents for indexing
            marking_doc = Document(text=marking_scheme)
            question_doc = Document(text=question_sheet)
            
            # Create vector store index
            index = VectorStoreIndex.from_documents([marking_doc, question_doc])
            
            # Generate analysis prompt
            prompt = f"""
            Based on the following:
            Marking Scheme: {marking_scheme}
            Question Sheet: {question_sheet}
            Student's Answer: {answer_sheet}
            
            Please provide a detailed analysis in the following JSON format:
            {{
                "evaluation": [
                    {{
                        "question_number": 1,
                        "points_awarded": 5,
                        "max_points": 10,
                        "feedback": "Detailed feedback here"
                    }}
                ],
                "overall_feedback": "General feedback about the entire submission",
                "total_score": 75,
                "max_possible_score": 100,
                "improvement_suggestions": [
                    "Suggestion 1",
                    "Suggestion 2"
                ]
            }}
            
            Ensure the response is a valid JSON object.
            """
            
            # Get response from Gemini
            response = self.model.generate_content(prompt)
            
            # Parse and validate response
            try:
                result = json.loads(response.text)
                # Validate required fields
                required_fields = ["evaluation", "overall_feedback", "total_score", "max_possible_score"]
                if not all(field in result for field in required_fields):
                    raise ValueError("Response missing required fields")
                return result
            except json.JSONDecodeError:
                return {
                    "error": "Failed to parse AI response",
                    "raw_response": response.text,
                    "status": "failed"
                }
            
        except Exception as e:
            return {
                "error": str(e),
                "status": "failed"
            } 