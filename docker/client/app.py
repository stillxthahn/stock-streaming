import os
import pandas as pd
import mysql.connector
from flask import Flask, jsonify, render_template_string
import requests

app = Flask(__name__)

API_URL = f"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=IBM&interval=5min&outputsize=full&datatype=csv&apikey=4I3GM8BWYMYZZO28"

current_line = 0 


INSERT_QUERY = """
INSERT IGNORE INTO IBM_STOCK (time, open, high, low, close, volume, symbol)
VALUES (%s, %s, %s, %s, %s, %s, %s);
"""

HOST = os.getenv("MYSQL_HOST")
print(HOST)

# Connect to the MySQL database
mysql_connection = mysql.connector.connect(
    host=HOST,
    port=3306,
    user="root",
    password="root",
    database="STOCK_STREAMING"
)
cursor = mysql_connection.cursor()  # Create a cursor

@app.route("/")
def home():
    """
    Home route displays the API documentation.
    """
    html_content = """
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="UTF-8">
        <title>Welcome to stillxthahn_ Stock API</title>
      </head>
      <body>
          <h1>Welcome to Stock API</h1>
          <p>Step 1: Fetch real-time IBM stock data and save it into stock-data.csv using the <code>/fetch</code> endpoint.</p>
          <p>Step 2: Get real-time stock data per request and insert it into the database using <code>/stock</code> endpoint.</p>
        </div>
      </body>
    </html>
    """
    return render_template_string(html_content)


@app.route("/fetch", methods=["GET"])
def fetch_data():
    """
    Fetch real-time IBM stock data and save it into stock-data.csv.
    """
    file_name = "stock-data.csv"
    response = requests.get(API_URL)
    with open(file_name, "wb") as file:
        file.write(response.content)

    data = pd.read_csv(file_name)
    data["timestamp"] = pd.to_datetime(data["timestamp"])
    data["symbol"] = "IBM"

    sorted_data = data.sort_values(by="timestamp", ascending=True)
    sorted_data.to_csv(file_name, index=False)
    return jsonify({"message": "Data initialized successfully"})


@app.route("/stock", methods=["GET"])
def insert_database():
    """
    Insert stock data into the database from stock-data.csv, one row per request.
    """
    global current_line

    df = pd.read_csv("stock-data.csv")

    if current_line >= len(df):
        current_line = 0  
        return jsonify({"error": "End of file reached, resetting to the first line"})

    row = df.iloc[current_line].to_dict()
    current_line += 1  

    # Insert into database
    cursor.execute(INSERT_QUERY, (
        row["timestamp"],
        row["open"],
        row["high"],
        row["low"],
        row["close"],
        row["volume"],
        row["symbol"]
    ))
    mysql_connection.commit()

    return jsonify(row)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port="8000")
