# AccuKnox AI/ML Internship: Problem Statement 1 & 2

This folder has 4 folders for the 5 sub-tasks in problem statement 1, and one document as a PDF for problem statement 2. Below is a description of each one of the 5 sub-tasks in problem statement 1, and how to run the files. For problem statement 2, please open the document 'Problem Statement 2'  

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

Assumption made: a real CSV upload will always have some messy or duplicate rows, so I cleaned the data before saving it instead of saving everything as is. 

## 4 & 5. Most complex Python and database code

**Python Code: Sugarscape Model** (`reference-code/sugarscape_model.py`)
An agent-based simulation of 800 agents foraging for sugar on a 250x250 grid. Each agent has randomly assigned vision, metabolism, and starting wealth, and every time step it looks around (based on its vision range), moves to the best unclaimed cell it can see, harvests sugar, and dies if it runs out of wealth. Ran for 1,000 time steps, then used pandas and seaborn to analyze how an agent's vision affects how long it survives.

**Database Code: TPM 13 Treasury Flow Query** (`reference-code/treasury_flow_query.sql`)
A SQL query built for SAP Treasury and Risk Management reporting at my previous internship. It joins 9 tables to pull transaction flow data (postings, valuations, interest calculations) for a set of financial product types, and handles real-world data issues such as deduplicating historical records with window functions, falling back between two different ID fields depending on product type, and safely parsing SAP's date formats.

## Before you run anything

```
pip install -r requirements.txt
```
