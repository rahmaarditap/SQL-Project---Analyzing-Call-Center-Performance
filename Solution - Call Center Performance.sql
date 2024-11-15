create database project;
use project;

select * from data_call_center limit 20;


-- 1. What is the average resolution time for each topic, calculated only for resolved calls, and how does it compare to the overall average resolution time?

with resolution_by_topic as(
	select topic,
		round(avg(time_to_sec(Talk_Duration)), 2)  as avg_resolution_time
	from data_call_center
	where Resolved_Status = 'Y'
	group by topic),
overall_resolution as(
	select round(avg(time_to_sec(Talk_Duration)), 2) as overall_avg_resolution
	from data_call_center
	where Resolved_Status = 'Y')
select rt.topic,
	   rt.avg_resolution_time,
	   ovr.overall_avg_resolution,
	   abs(rt.avg_resolution_time - ovr.overall_avg_resolution) as resolution_diff_in_second,
	   case
	   		when rt.avg_resolution_time > ovr.overall_avg_resolution then 'Slower than Average'
	   		else 'Faster than Average'
	   end as resolution_comparison 
from resolution_by_topic rt, overall_resolution ovr
order by avg_resolution_time;


-- 2. How to rank the agents with the best performance based on multiple criteria: resolution rate, answer rate, number of calls, average satisfaction?
with agent_performance1 as(
	select agent,
		   count(*) as total_calls,
		   round(avg(case when resolved_status = 'Y' then 1 else 0 end)*100, 2) as resolution_rate,
		   round(avg(Satisfaction_Rating), 2) as avg_satisfaction_rating
	from data_call_center
	where Answered_Status = 'Y'
	group by agent),
agent_performance2 as(
	select agent, 
	round(avg(case when answered_status = 'Y' then 1 else 0 end)*100, 2) as answered_rate
	from data_call_center 
	group by agent)
select ap1.agent, total_calls, answered_rate, 
	   resolution_rate, avg_satisfaction_rating,
	   rank() over(order by resolution_rate desc, answered_rate desc, total_calls desc, avg_satisfaction_rating desc) as performance_rank
from agent_performance1 ap1 join agent_performance2 ap2
on ap1.agent = ap2.agent;


-- 3. Which topics have the highest number of unresolved cases, and does the unresolved case affect the satisfaction rating?
		
with unresolved_calls as(
	select topic, 
		   count(*) as total_calls,
		   sum(case when Resolved_Status = 'N' then 1 else 0 end) as total_unresolved_status,
		   round(avg(Satisfaction_Rating), 3) as avg_satisfaction_rating
	from data_call_center 
	where Answered_Status = 'Y'
	group by Topic)
select topic,
	   round(total_unresolved_status / total_calls * 100, 2) as unresolved_percentage,
	   avg_satisfaction_rating
from unresolved_calls
group by topic
order by unresolved_percentage asc;
 

-- 4. Call frequency by day of the week
select 
    DAYOFWEEK(Date) as day_of_week, 
    COUNT(*) as Total_Calls
from data_call_center 
group by day_of_week
order by day_of_week;

-- 5. Does the speed of answering the call affect the satisfaction rating?

with speeds_status as(
	select Call_Id, Speed_of_answer_in_seconds, case 
			when Speed_of_answer_in_seconds < 30 then 'Fast'
			when Speed_of_answer_in_seconds between 31 and 60 then 'Moderate'
			when Speed_of_answer_in_seconds between 61 and 90 then 'Slow'
			else 'Very Slow'
	end as speed_status
	from data_call_center
	where Speed_of_answer_in_seconds is not null)
select speed_status, count(*) as total_calls, avg(Satisfaction_Rating) as avg_satisfaction_rating
from speeds_status ss join data_call_center dc on ss.call_id = dc.call_id
where dc.Speed_of_answer_in_seconds is not null
group by speed_status
order by avg_satisfaction_rating;

