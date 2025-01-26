import sys
import json
from assignment_analysis import AssignmentAnalysisService

def main():
    if len(sys.argv) != 4:
        print(json.dumps({
            "error": "Invalid number of arguments. Expected: marking_scheme, question_sheet, answer_sheet",
            "status": "failed"
        }))
        sys.exit(1)
    
    try:
        marking_scheme = sys.argv[1]
        question_sheet = sys.argv[2]
        answer_sheet = sys.argv[3]
        
        service = AssignmentAnalysisService()
        result = service.analyze_assignment(marking_scheme, question_sheet, answer_sheet)
        
        # Print result as JSON string
        print(json.dumps(result))
        sys.exit(0)
        
    except Exception as e:
        print(json.dumps({
            "error": str(e),
            "status": "failed"
        }))
        sys.exit(1)

if __name__ == "__main__":
    main() 