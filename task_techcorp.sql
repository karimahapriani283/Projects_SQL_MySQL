-- 1. identifikasi 3 pelanggan teratas berdasarkan total nominal pesanan
SELECT
	c.first_name,
	c.last_name,
SUM(o.total_amount) AS total_order_amount
FROM Customers AS c
JOIN Orders AS o 
	ON o.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_order_amount DESC
LIMIT 3;

-- 2. temukan rata-rata nominal pesanan untuk setiap pelanggan
SELECT
	c.first_name,
	c.last_name,
AVG(o.total_amount) AS average_order
FROM Customers AS c
JOIN Orders AS o
	ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- 3. temukan semua karyawan yang telah menyelesaikan lebih dari 4 tiket support
SELECT
	e.first_name,
	e.last_name,
COUNT(s.ticket_id) AS resolved_tickets
FROM Employees AS e
JOIN SupportTickets AS s
	ON e.employee_id = s.employee_id
WHERE s.status = 'resolved'
GROUP BY e.employee_id
HAVING resolved_tickets > 4;

-- 4. temukan semua produk yang belum pernah dipesan
SELECT
p.product_name
FROM Products AS p
LEFT JOIN OrderDetails AS od
	ON od.product_id = p.product_id
WHERE od.order_id IS NULL;

-- 5. hitung total pendapatan yang dihasilkan dari penjualan produk (total revenue)
SELECT
SUM(quantity * unit_price) AS total_revenue
FROM orderdetails;

-- 6. (a) temukan harga rata-rata produk untuk setiap kategori
SELECT
    category,
    AVG(price) AS avg_price
FROM Products
GROUP BY category;
-- (b) temukan kategori dengan rata-rata lebih dari $500
SELECT
    category,
    AVG(price) AS avg_price
FROM Products
GROUP BY category
HAVING avg_price > 500;

WITH cte_avg_price as (
SELECT category, avg(price) AS rerata
FROM Products
GROUP BY category
)
SELECT * FROM cte_avg_price WHERE rerata > 500;


-- 7. temukan pelanggan yang telah membuat setidaknya satu pesanan dengan total jumlah lebih dari $1000
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM Customers AS c
JOIN Orders AS o
    ON c.customer_id = o.customer_id
WHERE o.total_amount > 1000;

SELECT *
FROM Customers
WHERE
customer_id IN
(SELECT customer_id
FROM Orders
WHERE total_amount > 1000);