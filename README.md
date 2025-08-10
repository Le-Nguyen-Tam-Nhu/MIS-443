# Data Bank Analysis - MIS 443 Project

## Project Overview
The "Data Bank" project simulates a digital-only bank integrated with a secure distributed data storage platform. The objective of this project is to analyze datasets related to customer transactions and data allocations to provide insights into Data Bank’s operations. The analysis focuses on customer behavior, transaction patterns, and regional performance, aiming to inform business decisions such as customer segmentation, marketing strategies, and operational optimizations.

## Key Data Elements
- **Regions:** Information about different geographical regions where Data Bank operates.
- **Customer Nodes:** Details on customer allocation to specific nodes (data storage locations) along with their active dates.
- **Customer Transactions:** Records of customer financial activities, including deposits, withdrawals, and purchases made using their Data Bank debit card.

## SQL Queries and Insights
This project explores the application of SQL queries to uncover meaningful insights about customer behavior and system performance.

### 1. Customer Nodes Exploration
- **Question 1:** How many unique nodes are there on the Data Bank system?
- **Question 2:** What is the number of nodes per region?
- **Question 3:** How many customers are allocated to each region?
- **Question 4:** How many days on average are customers reallocated to a different node?
- **Question 5:** What is the median, 80th, and 95th percentile for reallocation days across regions?

### 2. Customer Transactions Analysis
- **Question 1:** What is the unique count and total amount for each transaction type?
- **Question 2:** What is the average total historical deposit counts and amounts for all customers?
- **Question 3:** For each month, how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
- **Question 4:** What is the closing balance for each customer at the end of the month?
- **Question 5:** What is the percentage of customers who increase their closing balance by more than 5%?

### 3. Data Allocation Challenge
- **Option 1:** Data allocated based on the amount of money at the end of the previous month.
- **Option 2:** Data allocated based on the average amount of money kept in the account in the previous 30 days.
- **Option 3:** Data updated in real-time.

Each option is analyzed to understand how much data would need to be provisioned on a monthly basis.

## Conclusion
This project demonstrates the application of SQL in analyzing customer data, understanding transaction patterns, and exploring different methods of data allocation. By deriving insights from the analysis, this report provides valuable recommendations for improving operational efficiency and customer engagement in Data Bank.

## Installation & Usage
1. Clone the repository:
