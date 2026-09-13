import requests   # lets Python make an HTTP request, same thing your browser does when it loads a page
import pandas as pd
import sqlite3    # Python's built-in library for talking to a SQLite database file

# STEP 1: Call the API
# Open Library has a free search API, no signup needed. We're asking for books matching "data science".
url = "https://openlibrary.org/search.json"
params = {"q": "data science", "limit": 20}     # limit = how many results we want back
response = requests.get(url, params=params)     # sends the request, waits for the API to reply
data = response.json()                          # turns the reply (raw text) into a Python dict

# STEP 2: Pull out just the 3 fields the task asks for, from each book
books_list = []
for book in data["docs"]:                       # data["docs"] is the list of books the API sent back
    books_list.append({
        "title": book.get("title"),
        "author": book.get("author_name", [None])[0],   # some books have several authors, we just keep the first
        "publication_year": book.get("first_publish_year")
    })

# STEP 3: Turn that list into a table - this part is pure pandas, nothing new
df = pd.DataFrame(books_list)
print(df.head())

# STEP 4: Save the table into a SQLite database file
conn = sqlite3.connect("books.db")               # creates the file if it doesn't already exist
df.to_sql("books", conn, if_exists="replace", index=False)   # writes the whole DataFrame as a table

# STEP 5: Read it back, to prove it's actually sitting in the database now
stored_books = pd.read_sql("SELECT * FROM books", conn)
print(stored_books)

conn.close()
