from flask import Flask, jsonify

app = Flask(__name__)     # creating the web application

STUDENT_SCORES = [
    {"student": "Aarav", "score": 78},
    {"student": "Diya", "score": 92},
    {"student": "Kabir", "score": 65},
    {"student": "Meera", "score": 88},
    {"student": "Rohan", "score": 74},
    {"student": "Sana", "score": 81},
    {"student": "Vivaan", "score": 59},
    {"student": "Ishaan", "score": 95},
]

@app.route("/api/scores")
def get_scores():
    return jsonify(STUDENT_SCORES)   

if __name__ == "__main__":
    app.run(port=5000)      
