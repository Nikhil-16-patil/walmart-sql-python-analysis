# ================================================
# WALMART SALES — DATA PREPARATION (Python)
# Cleans raw Walmart.csv and loads it into MySQL
# ================================================

import os
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

# ── Step 1: Load raw data ──────────────────────────
sales = pd.read_csv("Walmart.csv", encoding_errors="ignore")
print("Raw shape:", sales.shape)          # (10051, 11)
sales.head()
sales.describe()
sales.info()

# ── Step 2: Data quality check ─────────────────────
# Missing values found:
#   - unit_price: 31 missing
#   - quantity:   31 missing
# Data type issues found:
#   - unit_price: stored as str, needs conversion to float64
#   - date:       stored as str, needs conversion to datetime64
#   - time:       stored as str, needs conversion to proper time format
# Duplicates found: 51 rows

print("Duplicates:", sales.duplicated().sum())
print("Nulls:\n", sales.isnull().sum())

sales.drop_duplicates(inplace=True)
sales.dropna(inplace=True)
print("Shape after removing duplicates/nulls:", sales.shape)   # (9969, 11)

# ── Step 3: Fix data types ─────────────────────────
sales["unit_price"] = sales["unit_price"].str.replace("$", "", regex=False).astype(float)

sales["date"] = pd.to_datetime(sales["date"], errors="coerce")
sales["time"] = pd.to_datetime(sales["time"], format="%H:%M:%S", errors="coerce").dt.time
sales["datetime"] = pd.to_datetime(sales["date"].astype(str) + " " + sales["time"].astype(str))

# Re-check for any new nulls introduced by coercion during date/time parsing
print("Nulls after date/time conversion:\n", sales.isnull().sum())
sales.dropna(inplace=True)

# ── Step 4: Add computed column ────────────────────
# Rounded to 2 decimals to avoid floating-point artifacts (e.g. 522.8299999999999)
sales["total"] = (sales["unit_price"] * sales["quantity"]).round(2)

print("Final shape:", sales.shape)        # (9969, 12)
sales.head()

# ── Step 5: Load into MySQL ────────────────────────
# Credentials are read from environment variables, never hardcoded,
# so they are never exposed if this file is pushed to GitHub.
url = URL.create(
    drivername="mysql+pymysql",
    username=os.environ.get("DB_USER"),
    password=os.environ.get("DB_PASSWORD"),
    host="localhost",
    port=3306,
    database="walmart_db",
)
engine_sql = create_engine(url)
sales.to_sql("sales", con=engine_sql, if_exists="replace", index=False)

print("Loaded", len(sales), "rows into walmart_db.sales")
