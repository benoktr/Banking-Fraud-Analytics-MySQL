# Banking Fraud Analytics & Risk Detection — MySQL

## 📌 Project Overview

**Banking Fraud Analytics & Risk Detection** is an advanced MySQL data analytics project designed to analyze large-scale banking data and identify transaction patterns, fraud risks, customer behavior, loan performance, and account activity.

The project contains a **1M+ transaction banking database** with multiple related tables and advanced SQL queries for fraud detection, risk analysis, reporting, and performance optimization.

---

## 🎯 Project Objectives

* Analyze customer and account transaction behavior
* Identify suspicious and potentially fraudulent transactions
* Analyze fraud alerts and risk scores
* Monitor loan performance and repayment behavior
* Identify high-risk customers and merchants
* Analyze branch-level banking performance
* Detect transaction anomalies and unusual activity
* Practice advanced SQL and database optimization techniques

---

## 🛠️ Tech Stack

* **Database:** MySQL 8.0+
* **Language:** SQL
* **Tools:** MySQL Workbench / MySQL Command Line
* **Concepts:** Joins, CTEs, Subqueries, Window Functions, Views, Stored Procedures, Triggers, Indexing, EXPLAIN

---

## 📊 Dataset

The database contains large-scale simulated banking data:

| Data                |   Records |
| ------------------- | --------: |
| Customers           |   100,000 |
| Accounts            |   150,000 |
| Transactions        | 1,000,000 |
| Card Transactions   |   500,000 |
| Loan Records        |    50,000 |
| Loan Payments       |   500,000 |
| Merchants           |    20,000 |
| Fraud Alerts        |    50,000 |
| Customer Complaints |   100,000 |
| Branches            |       100 |
| Employees           |     2,000 |
| Beneficiaries       |   100,000 |

---

## 🗂️ Database Tables

The project includes the following major tables:

* `branches`
* `employees`
* `customers`
* `accounts`
* `merchants`
* `beneficiaries`
* `transactions`
* `card_transactions`
* `loans`
* `loan_payments`
* `fraud_alerts`
* `customer_complaints`

These tables are connected using primary keys and foreign-key relationships to support realistic banking analytics.

---

## 🔍 Key SQL Analysis

The project includes **50 advanced SQL challenges and solutions**, covering:

### Transaction Analysis

* Top customers by transaction value
* Customer average vs. bank average
* Running transaction totals
* Previous transaction analysis using `LAG()`
* Monthly transaction growth
* Transactions occurring within short time intervals
* Customers transacting across multiple cities
* High-value transaction anomalies

### Customer Risk Analysis

* Customer risk scoring
* High-income but low-activity customers
* Customers with repeated fraud alerts
* Dormant accounts with recent transaction attempts
* Customers with high fraud exposure
* Customer transaction activity across multiple months

### Fraud Detection

* Failed transactions within 24 hours
* Repeated card declines followed by approval
* High-risk merchants
* Fraud confirmation rates
* Fraud risk scores by merchant category
* Open fraud alerts
* False-positive analysis
* Highest confirmed fraud values

### Loan Analytics

* Loan repayment completion percentage
* Missed loan payments
* Average payment delay
* Branch loan default rates
* High loan-to-income customers
* Top loan types by branch
* Monthly loan collection analysis

### Complaint Analytics

* Complaint category ranking
* Complaint resolution time
* Critical unresolved complaints
* Customers with both complaints and fraud alerts

### Advanced SQL

The project demonstrates:

* `INNER JOIN`
* `LEFT JOIN`
* `GROUP BY`
* `HAVING`
* Subqueries
* CTEs
* `CASE`
* `LAG()`
* `DENSE_RANK()`
* `ROW_NUMBER()`
* `NTILE()`
* Aggregate functions
* Date/time analysis
* Standard deviation analysis
* Views
* Stored procedures
* Triggers
* Indexing
* `EXPLAIN`

---

## ⚡ Query Performance Optimization

Database performance was analyzed using MySQL's `EXPLAIN` command.

Indexes are used to improve performance for frequently queried columns such as:

* Customer IDs
* Account IDs
* Transaction IDs
* Merchant IDs
* Transaction dates
* Fraud alert information

Example:

```sql
EXPLAIN
SELECT
    customer_id,
    SUM(amount) AS total_transaction_value
FROM transactions
WHERE transaction_status = 'SUCCESS'
GROUP BY customer_id;
```

This helps analyze query execution plans and identify opportunities for optimization.

---

## 📁 Project Structure

Because the complete database SQL file is larger than GitHub's web-upload limit, the database has been divided into multiple SQL files.

```text
Banking-Fraud-Analytics-MySQL/
│
├── README.md
│
├── banking_fraud_analytics_part_01.sql
├── banking_fraud_analytics_part_02.sql
├── banking_fraud_analytics_part_03.sql
├── banking_fraud_analytics_part_04.sql
├── banking_fraud_analytics_part_05.sql
├── banking_fraud_analytics_part_06.sql
├── banking_fraud_analytics_part_07.sql
├── banking_fraud_analytics_part_08.sql
├── banking_fraud_analytics_part_09.sql
├── banking_fraud_analytics_part_10.sql
├── banking_fraud_analytics_part_11.sql
├── banking_fraud_analytics_part_12.sql
├── banking_fraud_analytics_part_13.sql
│
└── banking queries with answers.sql
```

---

## 🚀 How to Run the Project

### 1. Install MySQL

Use **MySQL 8.0 or later**.

You can use MySQL Workbench to execute the SQL files.

### 2. Clone the Repository

```bash
git clone https://github.com/YOUR-USERNAME/Banking-Fraud-Analytics-MySQL.git
```

### 3. Open MySQL Workbench

Connect to your MySQL server.

### 4. Execute SQL Files in Order

Run the database files in this order:

```text
part_01
part_02
part_03
part_04
part_05
part_06
part_07
part_08
part_09
part_10
part_11
part_12
part_13
```

**Important:** Execute the files sequentially because the database schema and data follow the original execution order.

### 5. Select the Database

The SQL script creates:

```sql
banking_fraud_analytics
```

Then run:

```sql
USE banking_fraud_analytics;
```

### 6. Verify the Database

For example:

```sql
SHOW TABLES;
```

Check transaction records:

```sql
SELECT COUNT(*)
FROM transactions;
```

Expected result:

```text
1000000
```

---

## 💡 Example Analysis Query

### Top 10 Customers by Successful Transaction Value

```sql
SELECT
    customer_id,
    SUM(amount) AS total_transaction_value
FROM transactions
WHERE transaction_status = 'SUCCESS'
GROUP BY customer_id
ORDER BY total_transaction_value DESC
LIMIT 10;
```

### Customer Ranking Within Branch

```sql
SELECT
    customer_id,
    branch_id,
    total_transaction_value,
    DENSE_RANK() OVER (
        PARTITION BY branch_id
        ORDER BY total_transaction_value DESC
    ) AS branch_rank
FROM customer_transaction_summary;
```

### Previous Transaction Analysis

```sql
SELECT
    customer_id,
    transaction_id,
    transaction_date,
    amount,
    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date
    ) AS previous_amount
FROM transactions;
```

---

## 📈 Skills Demonstrated

This project demonstrates practical experience in:

* SQL Development
* MySQL Database Management
* Data Analysis
* Fraud Detection
* Risk Analytics
* Banking Analytics
* Advanced SQL Queries
* Window Functions
* CTEs
* Query Optimization
* Database Indexing
* Data Validation
* Relational Database Design

---

## 🎓 Use Case

This project is suitable for demonstrating SQL and database skills for roles such as:

* SQL Developer
* Data Analyst
* Junior Data Analyst
* Database Developer
* Business Analyst
* Data Engineer — Fresher
* Banking Data Analyst

---

## 👨‍💻 Author

**AUSTIN BENO J S**

**B.E. Computer Science & Engineering**

VSB College of Engineering Technical Campus

---

## ⭐ Project Highlights

* 1M+ banking transactions
* 100K+ customers
* 150K accounts
* 50K fraud alerts
* 50 advanced SQL challenges
* Fraud and risk analytics
* Loan performance analysis
* Customer behavior analysis
* Window-function-based analytics
* Query performance optimization
* MySQL database design

---

⭐ If you find this project useful, consider giving the repository a star.

