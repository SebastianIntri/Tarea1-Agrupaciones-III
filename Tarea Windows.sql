with t as (
	select o.customer_id, extract(year from o.order_date) as perYear, extract(month from o.order_date) as perMonth,  extract(day from o.order_date) as perDay, sum((od.quantity * od.unit_price)) as monto 
	from order_details od join orders o using (order_id)
	group by o.customer_id, perYear, perMonth, perDay
	order by o.customer_id, perYear, perMonth, perDay
), s as (
	select t.customer_id, t.perYear, t.perMonth, t.monto, lag(monto,1) over w1 as monto_menos1
	from t
	window w1 as (partition by t.customer_id, t.perYear, t.perMonth order by t.customer_id, perYear, perMonth, perDay)
)

select s.customer_id, s.perYear, s.perMonth,  avg((s.monto - s.monto_menos1)) as diferencia_montos
from s
group by s.customer_id, s.perYear, s.perMonth
order by s.customer_id, s.perYear, s.perMonth;



