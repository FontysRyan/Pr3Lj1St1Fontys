from flask import Flask, request, jsonify
from sqlalchemy import create_engine, text, MetaData
from dotenv import load_dotenv
import os

# DATABASE-CONNECTIE

load_dotenv(override=True)

print(os.getenv('DB_USER'))
print(os.getenv('DB_PASS'))
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = (
    f"mysql+pymysql://"
    f"{os.getenv('DB_USER')}:{os.getenv('DB_PASS')}"
    f"@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

engine = create_engine(
    f"mysql+pymysql://"
    f"{os.getenv('DB_USER')}:{os.getenv('DB_PASS')}"
    f"@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
)
print(os.getenv('DB_USER'))

metadata = MetaData()
metadata.reflect(bind=engine)

# INSERT ENDPOINT
@app.route("/insert/<table_name>", methods=["POST"])
def insert_into(table_name):
    data = request.json
    cols = ", ".join(data.keys())
    placeholders = ", ".join(f":{col}" for col in data.keys())
    query = text(f"INSERT INTO {table_name} ({cols}) VALUES ({placeholders})")
    
    with engine.connect() as conn:
        conn.execute(query, data)
        conn.commit()
    
    return jsonify({"status": "success", "message": f"Inserted into {table_name}"}), 201

# SELECT ENDPOINT
@app.route("/select/<table_name>", methods=["GET"])
def select_from(table_name):
    filters = request.args.to_dict()
    query = f"SELECT * FROM {table_name}"
    
    if filters:
        conditions = " AND ".join(f"{k} = :{k}" for k in filters)
        query += f" WHERE {conditions}"

    query = text(query)

    with engine.connect() as conn:
        result = conn.execute(query, filters)
        rows = result.mappings().all()
    
    return jsonify(rows)

# DELETE ENDPOINT
@app.route("/delete/<table_name>", methods=["DELETE"])
def delete_from(table_name):
    filters = request.args.to_dict()
    if not filters:
        return jsonify({"error": "Je moet minimaal één filter meegeven."}), 400

    conditions = " AND ".join(f"{col} = :{col}" for col in filters)
    query = text(f"DELETE FROM {table_name} WHERE {conditions}")

    with engine.connect() as conn:
        result = conn.execute(query, filters)
        conn.commit()
    
    return jsonify({"deleted_rows": result.rowcount})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)