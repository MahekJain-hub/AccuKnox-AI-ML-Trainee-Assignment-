from flask import Flask, jsonify

app = Flask(__name__)     # creates your web application

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

@app.route("/api/scores")      # "when someone visits this URL, run the function below"
def get_scores():
    return jsonify(STUDENT_SCORES)   # jsonify turns your Python list into a proper JSON response

if __name__ == "__main__":
    app.run(port=5000)         # starts the server, listening on http://localhost:5000
