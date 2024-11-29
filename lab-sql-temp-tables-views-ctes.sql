-- Creating a Customer Summary Report
USE sakila;
-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. 
-- The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW bank.rental_information AS
SELECT sc.customer_id, CONCAT(sc.first_name, ' ', sc.last_name) AS full_name, lower(sc.email) as email, COUNT(sr.rental_id)as rental_count
FROM sakila.customer as sc
JOIN sakila.rental as sr
ON sc.customer_id = sr.customer_id
GROUP BY customer_id;

SELECT * FROM bank.rental_information;


-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.


CREATE TEMPORARY TABLE bank.total_paid AS
SELECT 
    bri.customer_id,
    bri.rental_count,
    SUM(sp.amount) AS amount_paid  
FROM 
    bank.rental_information AS bri
JOIN 
    sakila.payment AS sp
ON 
    bri.customer_id = sp.customer_id
GROUP BY 
    bri.customer_id, bri.rental_count;
    
    SELECT * FROM bank.total_paid;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and rental_count.

WITH customer_summary_report AS(
	SELECT bri.full_name, bri.email, bri.rental_count, btp.amount_paid as total_paid
    FROM bank.rental_information as bri
    JOIN bank.total_paid as btp
    ON bri.customer_id = btp.customer_id
)
SELECT 
    csr.full_name AS customer_name,
    csr.email, 
    csr.rental_count, 
    csr.total_paid,
    ROUND(csr.total_paid / csr.rental_count,2) AS average_payment_per_rental
FROM 
    customer_summary_report AS csr;
