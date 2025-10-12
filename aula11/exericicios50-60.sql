-- 50 Use LEAD() para prever próximo pagamento.
SELECT 
    customer_id,
    payment_date,
    amount,
    LEAD(payment_date) OVER (PARTITION BY customer_id ORDER BY payment_date) AS next_payment_date,
    LEAD(amount) OVER (PARTITION BY customer_id ORDER BY payment_date) AS next_payment_amount
FROM payments
ORDER BY customer_id, payment_date;

-- 51 Aplique DENSE_RANK() para ranquear salários por departamento.
SELECT 
    e.first_name,
    e.last_name,
    d.name AS department_name,
    e.salary,
    DENSE_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_rank
FROM employees e
JOIN departments d ON e.department_id = d.id
ORDER BY d.name, salary_rank;

-- 52 Use NTILE(4) para dividir clientes em quartis de gasto.
WITH customer_spending AS (
    SELECT 
        c.id,
        c.name,
        c.city,
        COALESCE(SUM(p.amount), 0) AS total_spent
    FROM customers c
    LEFT JOIN payments p ON c.id = p.customer_id
    GROUP BY c.id, c.name, c.city
)
SELECT 
    id,
    name,
    city,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_quartile
FROM customer_spending
ORDER BY spending_quartile, total_spent DESC;

-- 53 Calcule média móvel de 3 meses do faturamento.
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(payment_date, '%Y-%m') AS month_year,
        SUM(amount) AS monthly_amount
    FROM payments
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT 
    month_year,
    monthly_amount,
    AVG(monthly_amount) OVER (
        ORDER BY month_year 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3months
FROM monthly_revenue
ORDER BY month_year;

-- 54 Mostre participação (%) de cada produto no total da categoria.
SELECT 
    p.name AS product_name,
    c.name AS category_name,
    p.price,
    ROUND(
        (p.price / SUM(p.price) OVER (PARTITION BY p.category_id)) * 100, 
        2
    ) AS percentage_of_category
FROM products p
JOIN categories c ON p.category_id = c.id
ORDER BY c.name, percentage_of_category DESC;

-- 55 Gere um slug de produto (minúsculo, com hífen).
SELECT 
    name AS product_name,
    LOWER(
        REPLACE(
            REPLACE(
                REPLACE(name, ' ', '-'),
                '&', 'e'
            ),
            ' ', ''
        )
    ) AS product_slug
FROM products;

-- 56 Monte ID de pedido legível com ORD-AAAA-MM-id.
SELECT 
    id,
    CONCAT('ORD-', YEAR(order_date), '-', LPAD(MONTH(order_date), 2, '0'), '-', id) AS order_id_formatted
FROM orders;

-- 57 Mostre tempo médio entre order_date e shipped_date por shipper.
SELECT 
    shipper,
    COUNT(*) AS total_orders,
    AVG(TIMESTAMPDIFF(HOUR, order_date, shipped_date)) AS avg_hours_to_ship,
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_date, shipped_date)), 2) AS avg_days_to_ship
FROM orders 
WHERE shipped_date IS NOT NULL 
    AND status = 'Shipped'
GROUP BY shipper
ORDER BY avg_hours_to_ship;

-- 58 Monte relatório de pontualidade dos pedidos (ON_TIME ou LATE).
SELECT 
    id,
    customer_id,
    order_date,
    shipped_date,
    status,
    CASE 
        WHEN shipped_date IS NULL THEN 'PENDING'
        WHEN TIMESTAMPDIFF(DAY, order_date, shipped_date) <= 2 THEN 'ON_TIME'
        ELSE 'LATE'
    END AS punctuality_status,
    TIMESTAMPDIFF(DAY, order_date, shipped_date) AS days_to_ship
FROM orders
WHERE shipped_date IS NOT NULL
ORDER BY punctuality_status, days_to_ship;

-- 59 Liste funcionários com nome completo, anos de casa e salário reajustado.
SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    d.name AS department,
    TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS years_of_service,
    salary AS current_salary,
    ROUND(salary * 1.15, 2) AS adjusted_salary_15percent,
    ROUND(salary * 1.15 - salary, 2) AS salary_increase
FROM employees e
JOIN departments d ON e.department_id = d.id
ORDER BY years_of_service DESC;

-- 60 Crie ranking de cidades por valor total comprado e ticket médio.
WITH city_stats AS (
    SELECT 
        c.city,
        c.state,
        COUNT(DISTINCT o.id) AS total_orders,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_spent,
        COUNT(DISTINCT c.id) AS total_customers
    FROM customers c
    LEFT JOIN orders o ON c.id = o.customer_id
    LEFT JOIN order_items oi ON o.id = oi.order_id
    GROUP BY c.city, c.state
    HAVING total_spent IS NOT NULL
)
SELECT 
    city,
    state,
    total_orders,
    ROUND(total_spent, 2) AS total_spent,
    ROUND(total_spent / total_orders, 2) AS avg_ticket,
    RANK() OVER (ORDER BY total_spent DESC) AS spending_rank,
    RANK() OVER (ORDER BY total_spent / total_orders DESC) AS avg_ticket_rank
FROM city_stats
ORDER BY spending_rank;
