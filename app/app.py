from flask import Flask
import pymysql
import os

app = Flask(__name__)

def get_connection():
    return pymysql.connect(
        host=os.environ.get("DB_HOST"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASS"),
        database=os.environ.get("DB_NAME")
    )

@app.route("/")
def home():
    return "App is running!"

@app.route("/data")
def show_data():
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM test_table;")
    data = cursor.fetchall()
    connection.close()

    return str(data)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)