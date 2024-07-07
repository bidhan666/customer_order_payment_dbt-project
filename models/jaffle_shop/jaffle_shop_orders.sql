with orders as(
    SELECT
        id,
        user_id,
        order_date,
        status
    FROM {{ source("jaffle_shop", "orders") }}
),

stripe_payments AS (
    SELECT *
    FROM {{ ref('stripe_payments') }}
),

order_payment AS (
    SELECT
        user_id,
        orders.id,
        orders.order_date,
        orders.status AS order_status,
        stripe_payments.payment_id,
        stripe_payments.payment_method,
        stripe_payments.status AS payment_status,
        stripe_payments.amount,
        stripe_payments.created_at
    FROM orders
    LEFT JOIN stripe_payments ON orders.id = stripe_payments.order_id
)

SELECT * 
FROM order_payment
