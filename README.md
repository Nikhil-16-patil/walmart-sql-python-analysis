Walmart Sales — SQL & Python Data Analysis Project

Project Overview

Analysis of Walmart retail transactions across 100 branches, 6 product
categories, and ~98 cities in Texas, spanning 2019–2023. Raw data
was cleaned and transformed in Python (pandas), loaded into MySQL,
then analyzed with 15 business questions using aggregation, window
functions, and subqueries.


01_data_preparation.py — cleans Walmart.csv and loads it into MySQL.
02_data_analysis.sql — answers 15 business questions.


Data Cleaning Summary


Raw data: 10,051 rows, 11 columns.
Removed: 51 duplicate rows, 31 rows with missing unit_price/quantity.
Final dataset: 9,969 clean transactions.
Type fixes: unit_price (string with $ → float), date (string →
datetime), time (string → time).
Computed column: total = unit_price × quantity, rounded to 2 decimals
to avoid floating-point display artifacts.
Security: database credentials are read from environment variables,
never hardcoded in the script.


Business Questions Answered


What is the total revenue generated?
Which branch generated the highest revenue?
Which product category generated the highest revenue?
What is the highest-rated category overall, and the lowest-rated?
What payment method is used most frequently, and does it vary by city?
What is the busiest hour of the day for sales?
What is the busiest day of the week?
Which category has the highest average profit margin?
What is the best-selling category in each branch?
Which branches have an average rating below the overall average?
What is the revenue and profit contribution of each payment method?
How does revenue vary by time of day (Morning/Afternoon/Evening)?
Which city has the highest average transaction value?
What is the monthly revenue trend across all branches?
Which branch-category combination is the single most profitable pairing?


Key Findings


Total Revenue: ₹12,09,726.38 across 9,969 transactions.
Top Branch: WALM009 (₹25,688.34).
Top Categories (near tie): Fashion accessories (₹4,89,480.90) and Home
and lifestyle (₹4,89,250.06) together make up ~81% of total revenue.
Rating vs. Revenue Mismatch: Fashion accessories and Home and lifestyle
— the top 2 revenue categories — are also the 2 lowest-rated (5.78 and
5.74 avg, vs. an overall average of 5.83), a notable customer-experience risk.
Peak Hour: 3 PM is the single busiest hour; activity is concentrated
1 PM–8 PM and drops sharply after 9 PM.
Peak Day: Tuesday, though day-of-week demand is fairly even overall.
Payment Methods: Credit card is most used overall (4,256 transactions),
but Ewallet is actually the top method in 75 of ~98 individual cities —
an example of Simpson's Paradox in the data.
Below-Average Branches: 25 of 100 branches rate below the 5.83 overall
average; notably WALM074 (5.18 avg rating) is also the #2 branch by revenue.
Most Profitable Pairing: WALM029 × Home and lifestyle (₹5,759.26 profit),
reinforcing that the top revenue categories are also the top profit drivers
— despite their lower customer ratings.


Tools Used


Python (pandas) — data cleaning and transformation
MySQL 8.0+ — data storage and SQL analysis (CTEs, window functions)
GitHub — version control and portfolio


Project Structure

walmart-sql-analysis/
├── Walmart.csv
├── 01_data_preparation.py
├── 02_data_analysis.sql
└── README.md

How to Run


Set your MySQL credentials as environment variables:


bash   export DB_USER=your_mysql_username
   export DB_PASSWORD=your_mysql_password


Run 01_data_preparation.py to clean Walmart.csv and load it into a
walmart_db.sales table in MySQL.
Run 02_data_analysis.sql to answer all 15 business questions.
