import requests
import pandas as pd
import matplotlib.pyplot as plt

response = requests.get("http://localhost:5000/api/scores")   
scores_data = response.json()

df = pd.DataFrame(scores_data)
average_score = df["score"].mean()
print(f"Fetched {len(df)} records from the API.")
print(f"Average score: {average_score:.2f}")

plt.figure(figsize=(9, 5))
bars = plt.bar(df["student"], df["score"], color="steelblue")
plt.axhline(average_score, color="red", linestyle="--", label=f"Average = {average_score:.1f}")

plt.title("Student Test Scores")
plt.xlabel("Student")
plt.ylabel("Score")
plt.ylim(0, 100)
plt.legend()
plt.tight_layout()
plt.savefig("scores_bar_chart.png")
print("Chart saved to scores_bar_chart.png")
