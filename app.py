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
    args = request.args.to_dict()
    
    # Kolommen om op te halen, standaard '*'
    columns = args.pop("columns", "*")
    if columns != "*":
        column_list = [col.strip() for col in columns.split(",")]
        column_str = ", ".join(column_list)
    else:
        column_str = "*"
    
    # Filters (overige query parameters)
    query = f"SELECT {column_str} FROM {table_name}"
    
    if args:
        conditions = " AND ".join(f"{k} = :{k}" for k in args)
        query += f" WHERE {conditions}"

    query = text(query)

    with engine.connect() as conn:
        result = conn.execute(query, args)
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

# GET PRODUCTS BY WAREHOUSE ENDPOINT
@app.route("/select/products/by-warehouse/<int:warehouse_id>", methods=["GET"])
def get_products_by_warehouse(warehouse_id):
    try:
        query = text("""
            SELECT DISTINCT p.*
            FROM products p
            JOIN product_locations pl ON p.product_id = pl.product_id
            JOIN zones z ON pl.zone_id = z.zone_id
            WHERE z.warehouse_id = :warehouse_id
        """)

        with engine.connect() as conn:
            result = conn.execute(query, {"warehouse_id": warehouse_id})
            rows = [dict(row) for row in result.mappings().all()]

        return jsonify(rows)

    except Exception as e:
        print("ERROR:", str(e))
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)