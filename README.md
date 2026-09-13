# AccuKnox AI/ML Internship — Problem Statement 1

This folder has 4 files for the 3 sub-tasks in problem statement 1. Below is a description of what each one does, and how to run the files. 

## Task 1: Get data on books from an external API

File: `task1_books_api_to_sqlite.py`

What it does:
- Calls a free API called Open Library and asks for 20 books about "data science"
- Takes the title, author, and year from each book
- Saves them into a database file called `books.db`
- Reads the database back and prints it

Run it:
```
python task1_books_api_to_sqlite.py
```

Assumption made: Open Library doesn't have a "list all books" function, so I searched for a topic ("data science") instead. Some books don't have an author or a year listed by the API, so I kept those rows and left that field empty, instead of dropping the row. g

## Task 2: Get test scores from an API, and visualise the data

2 Files: `mock_scores_api.py` and `task2_fetch_scores.py`

What each of the files do:
- `mock_scores_api.py` is a tiny API I built myself, using Flask. It serves 8 students' scores as JSON.
- `task2_fetch_scores.py` calls that API, calculates the average score, and draws a bar chart with the average marked as a red line.

Run it (needs two terminals open):
```
# terminal 1: start the API and leave it running
python mock_scores_api.py

# terminal 2: this fetches data from it
python task2_fetch_scores.py
```

Assumption made: I couldn't find a free public API that gives student test scores, so I built a small one myself with Flask instead of hardcoding the numbers (As an attempt to do a real fetch over HTTP)

## Task 3: Read a CSV and insert into a SQLite Database

File: `task3_csv_to_sqlite.py` (uses `users.csv`)

What it does:
- Reads `users.csv`, which is assumed to have some duplicate/and unstandardised rows (missing names, unformatted emails and duplicated emails)
- Drops rows with a missing name or email
- Drops rows where the email doesn't have '@' in it (process to standardise)
- Drops repeated emails
- Saves the clean data into `users.db`
- Reads it back and prints it

Run it:
```
python task3_csv_to_sqlite.py
```

Assumption: a real CSV upload will always have some messy or duplicate rows, so I cleaned the data before saving it instead of saving everything as is. 

## 4 & 5. Links to my most complex Python and database code

1. Python Code: https://github.com/MahekJain-hub/AccuKnox-AI-ML-Trainee-Assignment-/blob/4b840a90ed7cfc33c1434a8760fd23500f81fccc/reference-code/sugarscape_model.py
2. 

## Before you run anything

```
pip install -r requirements.txt
```
