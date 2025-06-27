create table user_data(
ids int,
user_id	bigint,
question_id	int,
points	int,
submitted_at text,
username text
)
-- List All Distinct Users and Their Stats
select distinct user_id,username,count(question_id) as total_questions,sum(points) as total_points from user_data
group by 1,2 order by 4 desc
--Calculate the Daily Average Points for Each User
select  user_id,username,to_char(to_date(split_part(submitted_at,' ',1),'yyy-mm-dd'),'DD-MM') as days,round(avg(points)::numeric,2) as daily_average_points from user_data
group by 1,2,3 order by 1
--Find the Top 3 Users with the Most Correct Submissions for Each Day
with cte as(select*,dense_rank() over(partition by submit_date order by correct_count desc) as ranks from(
select split_part(submitted_at,' ',1) as submit_date,username,count(question_id) as correct_count from user_data
where points>0
group by 1,2 order by 1) as ranked_data)
select * from cte where ranks<4
--Find the Top 5 Users with the Highest Number of Incorrect Submissions
select user_id,username,count(question_id) as incorrect_submissions from user_data
where points<0
group by 1,2 order by 3 desc limit 5
--Find the Top 10 Performers for Each Week
with cte as(select *,dense_rank() over(partition by weeks order by total_points desc) as ranks from(
select extract(week from to_date(split_part(submitted_at,' ',1),'yyyy-mm-dd')) as weeks,user_id,username,count(question_id) as total_submissions,sum(points) as total_points from user_data
group by 1,2,3 order by 1 ) as ranked_data)
select * from cte where ranks<=10