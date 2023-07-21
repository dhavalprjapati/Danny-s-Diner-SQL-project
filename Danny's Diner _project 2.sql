use dannys_diner;
-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
    SUM(price) AS total_spent, customer_id
FROM
    sales s
        INNER JOIN
    menu m
GROUP BY customer_id;

-- 2.How many days has each customer visited the restaurant?
SELECT 
    COUNT(DISTINCT (order_date)) AS restaurant_visit,
    customer_id
FROM
    sales
GROUP BY customer_id;

-- 3.What was the first item from the menu purchased by each customer?
select m.product_name,m.price,t.order_number, t.customer_id from (select  product_id,customer_id,row_number() over (partition by customer_id order by order_date ) as order_number  from sales s) as t 
join menu m
on m.product_id = t.product_id
where t.order_number = 1;

-- 4.What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    COUNT(s.product_id), m.product_name
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
GROUP BY m.product_name;

-- 5.Which item was the most popular for each customer?
SELECT
    customer_id,
    product_id,
    product_name,
    order_count
FROM (
    SELECT
        s.customer_id,
        m.product_id,
        m.product_name,
        COUNT(*) AS order_count,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS item_rank
    FROM
        sales s
        JOIN menu m ON s.product_id = m.product_id
    GROUP BY
        s.customer_id, m.product_id, m.product_name
) AS ranked_items
WHERE
    item_rank = 1;
    
-- 6.Which item was purchased first by the customer after they became a member?
select product_name, customer_id,order_date from(select s.customer_id,product_name,me.join_date,s.order_date, row_number() over (partition by s.customer_id order by join_date) as num  
from menu m
join sales s
on m.product_id = s.product_id
join members me
on me.customer_id = s.customer_id
where s.order_date >=join_date) as t
where t.num = 1;

-- 7.Which item was purchased just before the customer became a member?

select product_name, customer_id,order_date from(select s.customer_id,product_name,me.join_date,s.order_date, row_number() over (partition by s.customer_id order by join_date) as num  
from menu m
join sales s
on m.product_id = s.product_id
join members me
on me.customer_id = s.customer_id
where s.order_date < join_date) as t
where t.num = 1;

-- 8.What is the total items and amount spent for each member before they became a member?
SELECT 
    SUM(t.price), t.customer_id
FROM
    (SELECT 
        s.customer_id, m.price, order_date
    FROM
        sales s
    JOIN menu m ON m.product_id = s.product_id) AS t
        JOIN
    members me ON me.customer_id = t.customer_id
WHERE
    join_date < order_date
GROUP BY customer_id;

-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
    customer_id,
    SUM(CASE
        WHEN m.product_id = 1 THEN price * 20
        ELSE price * 10
    END) total_point
FROM
    menu m
        JOIN
    sales s ON s.product_id = m.product_id
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
    s.customer_id,
    SUM(CASE
        WHEN
            DATE_ADD(join_date, INTERVAL 7 DAY) <= order_date
                AND DAY(join_date) <= 31
        THEN
            price * 20
        ELSE 0
    END) AS total_point
FROM
    menu m
        JOIN
    sales AS s ON s.product_id = m.product_id
        JOIN
    members me ON me.customer_id = s.customer_id
GROUP BY customer_id;











SELECT * FROM dannys_diner.members;
SELECT * FROM dannys_diner.menu;
SELECT * FROM dannys_diner.sales;