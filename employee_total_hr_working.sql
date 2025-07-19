select * from work.employees_login

select *,to_char(in_datetime,'YYYY-MM-DD') as date_ from work.employees_login

drop table work.emp_work_hr

truncate table work.emp_work_hr


create table work.emp_work_hr (
	employee_id integer,
 	total_entry list_dates[],
 	date_ date
)

create type list_dates as (
		day_ date,
		time_ timestamp
)

insert into work.emp_work_hr
with t as (
select * from work.employees_login where to_char(in_datetime,'YYYY-MM-DD') = '2025-06-02'
),
y as (
	select * from work.emp_work_hr where date_ = '2025-06-30'
)

select coalesce(t.employee_id,y.employee_id),
	   case when y.employee_id is null then array[row(to_char(t.in_datetime,'YYYY-MM-DD'),t.in_datetime):: list_dates]
	   	when t.employee_id is not null then y.total_entry || array[row(to_char(t.in_datetime,'YYYY-MM-DD'),t.in_datetime):: list_dates]
	   	else y.total_entry end as total_entry,
	   	coalesce(to_char(t.in_datetime,'YYYY-MM-DD') :: date ,to_char(y.date_+1,'YYYY-MM-DD') :: date) as date_
	from  y
	full join  t
	on y.employee_id  = t.employee_id
	and y.date_ = to_char(t.in_datetime,'YYYY-MM-DD') ::date
	

select * from work.emp_work_hr where date_ = '2025-06-02'

with cte as (
select *,to_char(in_datetime,'YYYY-MM-DD') :: date as date_ from work.employees_login),
agg as (
select employee_id,
ARRAY_AGG(in_datetime) over (partition by employee_id,date_ )  as total_in_time,
ARRAY_AGG(out_datetime) over (partition by employee_id,date_ ) as total_out_time,
date_
from cte),
fr_in_ls_out as
(select distinct employee_id,(total_in_time[1] :: timestamp) as first_in ,(total_out_time[cardinality(total_out_time)] ::timestamp) as last_out,date_ from agg
order by employee_id, date_)
select employee_id,date_, extract(hour from (last_out - first_in)) as total_hr from fr_in_ls_out

select * from work.employees_login where employee_id = 1 order by in_datetime
