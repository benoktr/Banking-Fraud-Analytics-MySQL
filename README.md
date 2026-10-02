# 🏦 Banking Fraud Analytics & Risk Detection — MySQL

A large-scale **MySQL banking analytics and fraud detection project** designed to analyze customer transactions, account activity, loan performance, merchant behavior, complaints, and fraud alerts.

The project contains **1M+ banking transactions** and demonstrates advanced SQL techniques including **JOINs, CTEs, subqueries, window functions, LAG(), DENSE_RANK(), NTILE(), views, stored procedures, triggers, indexing, and EXPLAIN-based query optimization**.

---

## 📌 Project Overview

The objective of this project is to build a realistic banking database that can be used for:

- Customer transaction analysis
- Fraud detection
- Customer risk analysis
- Account activity monitoring
- Loan performance analysis
- Merchant fraud analysis
- Complaint analysis
- Transaction anomaly detection
- Branch performance analysis
- SQL query optimization

The database contains millions of records distributed across multiple banking entities such as customers, accounts, transactions, loans, merchants, fraud alerts, and complaints.

---

## 🛠️ Tech Stack

- **Database:** MySQL 8.0+
- **Language:** SQL
- **Tools:** MySQL Workbench / MySQL Command Line
- **Query Techniques:** CTEs, Subqueries, JOINs, Window Functions
- **Performance:** Indexing, EXPLAIN
- **Data Analysis:** Aggregations, Ranking, Time-Series Analysis

---

## 📊 Dataset

| Table | Records |
|---|---:|
| Customers | 100,000 |
| Accounts | 150,000 |
| Transactions | 1,000,000 |
| Card Transactions | 500,000 |
| Loans | 50,000 |
| Loan Payments | 500,000 |
| Merchants | 20,000 |
| Fraud Alerts | 50,000 |
| Customer Complaints | 100,000 |
| Branches | 100 |
| Employees | 2,000 |
| Beneficiaries | 100,000 |

### Total

**3M+ records across the banking database**

---

## 🗄️ Database Structure

The database contains the following major tables:

```text
banking_fraud_analytics
│
├── branches
├── employees
├── customers
├── accounts
├── merchants
├── beneficiaries
├── transactions
├── card_transactions
├── loans
├── loan_payments
├── fraud_alerts
└── customer_complaints
