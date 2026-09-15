import requests   
import pandas as pd
import sqlite3   

#Calling the API
url = "https://openlibrary.org/search.json"
params = {"q": "data science", "limit": 20}     # limit = how many results we want back
response = requests.get(url, params=params)     # sends the request, waits for the API to reply
data = response.json()                          # turns the reply (raw text) into a Python dict

# Pulling out 3 fields
books_list = []
for book in data["docs"]:                       
    books_list.append({
        "title": book.get("title"),
        "author": book.get("author_name", [None])[0],   # some books have several authors so keep the first one
        "publication_year": book.get("first_publish_year")
    })

# Turn the list into a dataframe
df = pd.DataFrame(books_list)
print(df.head())

# Save the table into a SQLite database file
conn = sqlite3.connect("books.db")               # creates the file if it doesn't already exist
df.to_sql("books", conn, if_exists="replace", index=False)   # writes the whole dataframe as a table

# Read it back
stored_books = pd.read_sql("SELECT * FROM books", conn)
print(stored_books)

conn.close()
