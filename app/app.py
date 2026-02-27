from flask import Flask, render_template, request, redirect, url_for
from dotenv import load_dotenv
import os
import pymysql

load_dotenv()

app = Flask(__name__)

def get_connection():
    return pymysql.connect(
        host=os.getenv("DB_HOST"),
        port=int(os.getenv("DB_PORT", 3306)),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASS"),
        database=os.getenv("DB_NAME")
    )

@app.route("/")
def home():
    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS test_table (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100),
                value VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        connection.commit()

        cursor.execute("SELECT * FROM test_table;")
        data = cursor.fetchall()

        connection.close()
        return render_template("index.html", data=data)

    except Exception as e:
        return f"Database Error: {str(e)}", 200


@app.route("/add", methods=["GET", "POST"])
def add():
    if request.method == "POST":
        name = request.form.get("name")
        value = request.form.get("value")

        connection = get_connection()
        cursor = connection.cursor()
        cursor.execute(
            "INSERT INTO test_table (name, value) VALUES (%s, %s)",
            (name, value)
        )
        connection.commit()
        connection.close()

        return redirect(url_for("home"))

    return render_template("add.html")


@app.route("/delete/<int:record_id>")
def delete(record_id):
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("DELETE FROM test_table WHERE id=%s", (record_id,))
    connection.commit()
    connection.close()
    return redirect(url_for("home"))


@app.route("/health")
def health():
    return "healthy", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)