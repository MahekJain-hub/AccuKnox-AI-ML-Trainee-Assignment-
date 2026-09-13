import pandas as pd
import sqlite3

df = pd.read_csv("users.csv")
total_read = len(df)
print(f"Read {total_read} rows from the CSV.")

# Real CSVs are never perfectly clean, so this step is the one that actually matters:
df = df.dropna(subset=["name", "email"])                    # drop rows missing a name or email
df = df[df["email"].str.contains("@", na=False)]             # drop rows without a valid-looking email
df = df.drop_duplicates(subset=["email"], keep="first")      # drop duplicate emails

print(f"{total_read - len(df)} rows dropped (missing fields, invalid email, or duplicate). {len(df)} rows remain.")

conn = sqlite3.connect("users.db")
df.to_sql("users", conn, if_exists="replace", index=False)

stored_users = pd.read_sql("SELECT * FROM users", conn)
print(stored_users)
conn.close()
