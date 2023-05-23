select 
	CONCAT(new_table.first_name, ' ', new_table.last_name) as name,
	count(new_table.sales_id) as operations,
	SUM(sold) as income
from (
	select 
		s.sales_id as sales_id,
		e.first_name,
		e.last_name,
		p."name",
		p.price * s.quantity as sold
	from sales s 
	inner join products p on p.product_id = s.product_id 
	inner join employees e on e.employee_id = s.sales_person_id) as new_table
group by CONCAT(new_table.first_name, ' ', new_table.last_name)
order by income desc 
limit 10;

select 
	CONCAT(new_table.first_name, ' ', new_table.last_name) as name,
	round(AVG(sold)) as average_income
from (
	select 
		s.sales_id as sales_id,
		e.first_name,
		e.last_name,
		p."name",
		p.price * s.quantity as sold
	from sales s 
	inner join products p on p.product_id = s.product_id 
	inner join employees e on e.employee_id = s.sales_person_id) as new_table
group by CONCAT(new_table.first_name, ' ', new_table.last_name)
having round(AVG(sold)) < (
	select round(AVG(p.price * s2.quantity))
	from sales s2
	inner join products p on s2.product_id = p.product_id 
)
order by average_income;

select 
	res.name,
	res.weekday,
	res.income
from (
	select 
		CONCAT(new_table.first_name, ' ', new_table.last_name) as name,
		to_char(new_table.sale_date, 'd') as weekday_number,
		to_char(new_table.sale_date, 'day') as weekday,
		round(SUM(sold)) as income
	from (
		select 
			s.sales_id as sales_id,
			e.first_name,
			e.last_name,
			p."name",
			p.price * s.quantity as sold,
			s.sale_date as sale_date
		from sales s 
		inner join products p on p.product_id = s.product_id 
		inner join employees e on e.employee_id = s.sales_person_id
		) as new_table
	group by
		to_char(new_table.sale_date, 'd'),
		to_char(new_table.sale_date, 'day'),
		CONCAT(new_table.first_name, ' ', new_table.last_name)
	order by to_char(new_table.sale_date, 'd') asc, income desc
	) as res;