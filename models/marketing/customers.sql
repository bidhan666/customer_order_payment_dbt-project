WITH customers AS (
    SELECT * 
    FROM {{ ref("jaffle_shop_customers") }}
),

orders AS (
    SELECT *
    FROM {{ ref('jaffle_shop_orders') }}
),

stripe_payments AS (
    SELECT *
    FROM {{ ref('stripe_payments') }}
),

customer_orders AS (
    SELECT
        orders.user_id,
        MIN(orders.order_date) AS first_order,
        MAX(orders.order_date) AS most_recent_order,
        COUNT(orders.id) AS number_of_orders,
        SUM(stripe_payments.amount) AS total_amount_paid,
        COUNT(stripe_payments.payment_id) AS number_of_payments,
        MIN(stripe_payments.created_at) AS first_payment,
        MAX(stripe_payments.created_at) AS most_recent_payment,
        STRING_AGG(DISTINCT stripe_payments.payment_method, ', ') AS payment_methods
    FROM orders
    LEFT JOIN stripe_payments ON orders.id = stripe_payments.order_id
    GROUP BY orders.user_id
),

final AS (
    SELECT
        customers.first_name,
        customers.last_name,
        customer_orders.first_order,
        customer_orders.most_recent_order,
        customer_orders.number_of_orders,
        customer_orders.total_amount_paid,
        customer_orders.number_of_payments,
        customer_orders.first_payment,
        customer_orders.most_recent_payment,
        customer_orders.payment_methods
    FROM customers
    LEFT JOIN customer_orders ON customers.id = customer_orders.user_id
)

SELECT * 
FROM final
