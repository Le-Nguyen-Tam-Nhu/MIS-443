
-- A. Customer Nodes Exploration

-- 1. How many unique nodes are there on the Data Bank system?
SELECT
	COUNT(DISTINCT node_id) AS total_unique_nodes
FROM
	data_bank.customer_nodes;
	
-- 2. What is the number of nodes per region?

SELECT
	rg.region_name, COUNT(DISTINCT nd.node_id) AS total_nodes
FROM
	data_bank.customer_nodes AS nd
INNER JOIN
	data_bank.regions AS rg ON rg.region_id = nd.region_id
GROUP BY
	rg.region_name
ORDER BY
	rg.region_name;
	
-- 3. How many customers are allocated to each region?

SELECT
	rg.region_name, COUNT(DISTINCT nd.customer_id) AS total_customers
FROM
	data_bank.customer_nodes AS nd
INNER JOIN 
	data_bank.regions AS rg ON rg.region_id = nd.region_id
GROUP BY
	rg.region_name
ORDER BY
	total_customers DESC;
	
-- 4. How many days on average are customers reallocated to a different node?

WITH active_days_in_nodes AS 
	(SELECT 
  		nd.customer_id,
		nd.node_id,
		SUM(nd.end_date - nd.start_date) AS active_days_in_nodes
	FROM
		data_bank.customer_nodes AS nd
	WHERE
		end_date != '9999-12-31'
	GROUP BY
		nd.customer_id, nd.node_id
	ORDER BY
		customer_id, node_id)
SELECT round(AVG(adin.active_days_in_nodes)) AS active_days_in_nodes 
FROM active_days_in_nodes AS adin

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

SELECT
	rg.region_name,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nd.end_date - nd.start_date) AS median_days,
	PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY nd.end_date - nd.start_date) AS p80_days,
	PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY nd.end_date - nd.start_date) AS p95_days
FROM
	data_bank.customer_nodes AS nd
INNER JOIN
	data_bank.regions AS rg ON rg.region_id = nd.region_id
WHERE
	end_date != '9999-12-31'
GROUP BY
	rg.region_name
ORDER BY
	rg.region_name;


-- B. Customer Transactions
-- 1. What is the unique count and total amount for each transaction type?

SELECT
	txn_type,
	COUNT(customer_id) AS total_transactions,
	sum(txn_amount) AS total_amount
FROM
	data_bank.customer_transactions
GROUP BY
	txn_type
ORDER BY
	txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?

WITH avg_deposit_amount AS 
(SELECT 
	customer_id,
	COUNT(customer_id) AS total_deposit_times,
	AVG(txn_amount) AS total_deposit_amount
FROM
	data_bank.customer_transactions
WHERE
	txn_type = 'deposit'
GROUP BY customer_id
ORDER BY customer_id)
SELECT
	round(AVG(total_deposit_times))AS average_deposit_times,
	round(AVG(total_deposit_amount))AS average_deposit_amount
FROM
	avg_deposit_amount;

-- 3. For each month - how many Data Bank customers make 
-- more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH customer_dep_pur_with_count AS (SELECT 
	customer_id, 
	EXTRACT(MONTH FROM txn_date) AS month, 
	SUM(CASE WHEN txn_type = 'deposit' then 1 else 0 end) AS total_deposit_count,
	SUM(CASE WHEN txn_type = 'purchase' then 1 else 0 end) AS total_purchase_count,
	SUM(CASE WHEN txn_type = 'withdrawal' then 1 else 0 end) AS total_withdrawal_count
FROM 
	data_bank.customer_transactions
GROUP BY
	customer_id, month
ORDER BY
	customer_id, month)
SELECT 
	MONTH, COUNT(DISTINCT customer_id) AS total_customers
FROM 
	customer_dep_pur_with_count
WHERE
	total_deposit_count > 1 AND (total_purchase_count >= 1 OR total_withdrawal_count >=1)
GROUP BY month
ORDER BY month;
	
-- 4. What is the closing balance for each customer at the end of the month?

SELECT
  customer_id,
  txn_month,
  SUM(net_change) 
  OVER (PARTITION BY customer_id
    ORDER BY txn_month) AS closing_balance
FROM (
  SELECT
    customer_id,
    DATE_TRUNC('month', txn_date) AS txn_month,
    SUM(
      CASE
        WHEN txn_type = 'deposit' THEN txn_amount
        WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
        ELSE 0
      END
    ) AS net_change
  FROM data_bank.customer_transactions
  GROUP BY customer_id, DATE_TRUNC('month', txn_date)
) AS monthly_change
ORDER BY customer_id, txn_month;


-- 5. What is the percentage of customers who increase their closing balance by more than 5%?

WITH monthly_closing_balance AS (
    SELECT
        customer_id,
        EXTRACT(MONTH FROM txn_date) AS month,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
            ELSE 0
        END) AS balance
    FROM data_bank.customer_transactions
    GROUP BY customer_id, month
	ORDER BY customer_id, month
),
balance_with_previous AS (SELECT
        customer_id,
        month,
        balance,
        LAG(balance) OVER (PARTITION BY customer_id ORDER BY month) AS prev_balance
    FROM monthly_closing_balance
),
increase_over_5_percent AS (SELECT *
    FROM balance_with_previous
    WHERE prev_balance IS NOT NULL AND balance > prev_balance AND ((balance/prev_balance) > 1.05 )
),
final_percentage as (SELECT 
        COUNT(DISTINCT customer_id) * 100.0 /
        (SELECT COUNT(DISTINCT customer_id) FROM data_bank.customer_transactions) AS percent_increased
    FROM increase_over_5_percent)

SELECT round(percent_increased,2) || '%' AS increase_over_5_percent FROM final_percentage;

/*
C. Data Allocation Challenge
To test out a few different hypotheses - the Data Bank team wants to 
run an experiment where different groups of customers would be allocated data using 3 different options:
	Option 1: data is allocated based off the amount of money at the end of the previous month
	Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
	Option 3: data is updated real-time
For this multi-part challenge question - you have been requested to generate the following data elements 
to help the Data Bank team estimate how much data will need to be provisioned for each option:
	- running customer balance column that includes the impact each transaction
	- customer balance at the end of each month
	- minimum, average and maximum values of the running balance for each customer
Using all of the data available - how much data would have been required for each option on a monthly basis?
*/
-- running customer balance column that includes the impact each transaction
SELECT customer_id, 
       txn_date,
	   txn_type,
	   txn_amount,
       SUM(CASE 
               WHEN txn_type = 'deposit' THEN txn_amount
               WHEN txn_type IN ('withdrawal', 'purchase') THEN - txn_amount
               ELSE 0
           END) OVER (PARTITION BY customer_id ORDER BY txn_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
FROM data_bank.customer_transactions;

-- customer balance at the end of each month
SELECT
  customer_id,
  end_of_month,
  SUM(net_change) 
  OVER (PARTITION BY customer_id
    ORDER BY end_of_month) AS closing_balance
FROM (
  SELECT
    customer_id,
    EXTRACT(MONTH FROM txn_date) AS end_of_month,
    SUM(
      CASE
        WHEN txn_type = 'deposit' THEN txn_amount
        WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
        ELSE 0
      END
    ) AS net_change
  FROM data_bank.customer_transactions
  GROUP BY customer_id, end_of_month
  ORDER BY customer_id, end_of_month
) AS monthly_change
ORDER BY customer_id, end_of_month;

-- minimum, average and maximum values of the running balance for each customer

WITH running_balance AS (
    SELECT customer_id,
           txn_date,
           txn_type,
           txn_amount,
           SUM(CASE 
                   WHEN txn_type = 'deposit' THEN txn_amount
                   WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
                   ELSE 0
               END) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_balance
    FROM data_bank.customer_transactions
)
SELECT customer_id,
       MIN(running_balance) AS min_balance,
       AVG(running_balance) AS avg_balance,
       MAX(running_balance) AS max_balance
FROM running_balance
GROUP BY customer_id
ORDER BY customer_id;



