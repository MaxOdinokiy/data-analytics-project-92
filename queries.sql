select count(*) as customers_count 
from customers c;

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

select 
	case 
		when age between 10 and 15 then '10-15'
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		else '40+'
	end as age_category,
	count(c.customer_id) as count
from customers c 
group by age_category
order by age_category;

select
	customers_sales.sale_date as date,
	count(distinct customers_sales.customer_id) as total_customers,
	sum(customers_sales.sale_income) as income
from (
	select
		s.sales_id,
		s.customer_id,
		to_char(s.sale_date, 'YYYY-MM') as sale_date, 
		s.quantity * p.price as sale_income
	from sales s 
	inner join products p on p.product_id = s.sales_id
	order by s.customer_id 
	) as customers_sales
group by customers_sales.sale_date
order by customers_sales.sale_date;


select 	
	s2.customer,
	s2.sale_date,
	s2.seller
from (
	select 
		s.customer_id,
		concat(c.first_name, ' ', c.last_name) as customer,
		s.sale_date,
		row_number() over(partition by s.customer_id order by s.sale_date) as row_number,
		s.sales_person_id,
		concat(e.first_name, ' ', e.last_name) as seller,
		s.product_id 
	from sales s
	join products p on p.product_id = s.product_id 
	join employees e on e.employee_id = s.sales_person_id 
	join customers c on c.customer_id =s.customer_id 
	where p.price = 0
	order by s.customer_id
) as s2	
where s2.row_number = 1;