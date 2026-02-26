from flask import Flask, render_template, request, redirect, url_for
import pymysql
import os

app = Flask(__name__)

# Database connection
def get_connection():
    return pymysql.connect(
        host=os.environ.get("DB_HOST"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASS"),
        database=os.environ.get("DB_NAME")
    )

# Home page: show all data
@app.route("/")
def home():
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM test_table;")
    data = cursor.fetchall()
    connection.close()
    return render_template("index.html", data=data)

# Add new record page
@app.route("/add", methods=["GET", "POST"])
def add():
    if request.method == "POST":
        name = request.form.get("name")
        value = request.form.get("value")

        connection = get_connection()
        cursor = connection.cursor()
        cursor.execute("INSERT INTO test_table (name, value) VALUES (%s, %s)", (name, value))
        connection.commit()
        connection.close()
        return redirect(url_for("home"))
    return render_template("add.html")

# Delete record
@app.route("/delete/<int:record_id>")
def delete(record_id):
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("DELETE FROM test_table WHERE id=%s", (record_id,))
    connection.commit()
    connection.close()
    return redirect(url_for("home"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)