from flask import Flask, request, jsonify
from sqlalchemy import create_engine, text, MetaData
from dotenv import load_dotenv
import os

app = Flask(__name__)

# DATABASE-CONNECTIE
engine = create_engine("mysql+pymysql://vsadmin:visupapa@192.168.133.123:3306/visustore")
with engine.connect() as conn:
    print("Verbonden met de database.")
metadata = MetaData()
metadata.reflect(bind=engine)


#-------------------Testen van connectie-------------------

# def insert_into(table_name: str, data: dict):
#     """
#     Insert een rij in de opgegeven tabel via SQLAlchemy Core.
#     """
#     # 1. Table-object ophalen
#     if table_name not in metadata.tables:
#         raise ValueError(f"Tabel '{table_name}' niet gevonden in metadata.")
#     table = metadata.tables[table_name]

#     # 2. Insert-statement bouwen
#     stmt = table.insert().values(**data)

#     # 3. Uitvoeren
#     with engine.connect() as conn:
#         conn.execute(stmt)
#         conn.commit()
#         print(f"1 rij toegevoegd aan {table_name}.")

# # Voorbeeldgebruik:
# insert_into("warehouses", {
#     "name": "East Hub",
#     "address": "Laan 10",
#     "city": "Utrecht",
#     "postal_code": "3500BB"
# })


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

# # SELECT ENDPOINT
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

# # DELETE ENDPOINT
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