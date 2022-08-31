# https://leetcode.com/problems/exchange-seats/
with temp as
(select id, student, (case when id%2=0 then id-1 else id end) as new_id from seat),
temp2 as
(select id, student, lag(student,1) over(partition by new_id order by id asc) as lag_student, lead(student,1) over(partition by new_id order by id asc) as lead_student from temp),
temp3 as
(select id, student,(case when id%2 = 0 then lag_student else lead_student end) as student2 from temp2)
select id, ifnull(student2,student) as student
from temp3
order by id asc;

# https://leetcode.com/problems/new-users-daily-count/
# for this question, we need to notice that where we need to put our time limitation
with temp1 as
(select user_id, activity, activity_date from traffic where activity="login"),
temp2 as
(select user_id, activity_date, row_number() over(partition by user_id order by activity_date asc) as numb from temp1),
temp3 as
(select user_id, activity_date from temp2 where numb=1 and activity_date>="2019-04-01" and activity_date<="2019-06-30")
select activity_date as login_date, count(distinct user_id) as user_count
from temp3
group by activity_date

# https://leetcode.com/problems/user-purchase-platform/
select c.spend_date, c.platform, sum(coalesce(amount,0)) total_amount, sum(case when amount is null then 0 else 1 end) total_users 
    from
    
    (select distinct spend_date, 'desktop' platform from spending 
    union all
    select distinct spend_date, 'mobile' platform from spending 
    union all
    select distinct spend_date, 'both' platform from spending) c
    
    left join
    
    (select user_id, spend_date, case when count(*)=1 then platform else 'both' end platform, sum(amount) amount 
        from spending group by user_id, spend_date) v
    
    on c.spend_date=v.spend_date and c.platform=v.platform
    group by spend_date, platform;

# https://leetcode.com/problems/activity-participants/
# must notice that they will have multiple max or min value
with temp as
(select activity, count(id) as numb from friends group by activity order by numb asc limit 1),
temp2 as
(select activity, count(id) as numb from friends group by activity order by numb desc limit 1)
select activity from friends group by activity having count(id) != (select numb from temp) and count(id)!= (select numb from temp2)

# https://leetcode.com/problems/rectangles-area/
# how to remove the symmetric pair of points
with temp as
(select p1.id as a, p1.x_value as b, p1.y_value as c, p2.id as d, p2.x_value as e, p2.y_value as f from points as p1 join points as p2 on p1.x_value!=p2.x_value and p1.y_value!=p2.y_value)
select a as p1, d as p2, abs(b-e)*abs(c-f) as area
from temp
where a<d
order by area desc, p1 asc, p2 asc;

# https://leetcode.com/problems/fix-product-name-format/
# please do not forget trim function instead of strip to remove the redundant space
with temp as
(select lower(trim(product_name)) as product_name, date_format(sale_date,"%Y-%m") as sale_date from sales)
select product_name, sale_date, count(*) as total
from temp
group by product_name, sale_date
order by product_name asc, sale_date asc;