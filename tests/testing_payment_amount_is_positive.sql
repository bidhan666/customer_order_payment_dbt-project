with positive_payment as (select * from {{ ref("stripe_payments") }})

select payment_id, sum(amount)
from positive_payment
group by payment_id
having sum(amount) < 0
