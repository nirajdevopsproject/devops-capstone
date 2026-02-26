from flask import Flask
import pymysql
import os

app = Flask(__name__)

@app.route("/")
def home():
    connection = pymysql.connect(
        host=os.environ.get("DB_HOST"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASS"),
        database=os.environ.get("DB_NAME")
    )

    cursor = connection.cursor()
    cursor.execute("SELECT VERSION();")
    data = cursor.fetchone()
    connection.close()

    return f"MySQL Version: {data}"
@app.route("/data")
def show_data():
    connection = pymysql.connect(
        host=os.environ.get("DB_HOST"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASS"),
        database=os.environ.get("DB_NAME")
    )

    cursor = connection.cursor()
    cursor.execute("SELECT * FROM test_table;")
    data = cursor.fetchall()
    connection.close()

    return str(data)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
