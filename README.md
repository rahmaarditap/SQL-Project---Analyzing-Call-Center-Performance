# 📞 [SQL Project] Analyzing Call Center Performance 

## Tables of Contents
- [Introduction](#introduction)
- [Dataset](#dataset)
- [SQL Techniques Used](#sql-techniques-used)
- [Business Questions](#business-questions)

  
## Introduction
This project demonstrates the use of SQL to analyze and optimize call center performance. The dataset includes information about calls, agents, and customers' satisfaction rating. By exploring the data, this analysis uncovers trends, identifies areas for improvement, and provides actionable insights to enhance overall efficiency and customer satisfaction.
**The insights derived from this analysis can guide managers in implementing data-driven to enhancing call center performance.**

## Dataset
The dataset includes 5000 call center records with the following attributes:
1. ``Call_ID``: Unique identifier for each call.
2. ``Agent``: Agent handling the call.
3. ``Date``: Date of the call.
4. ``Time``: Start time of the call.
5. ``Topic``: Call topic category.
6. ``Answered_status``: Whether the call was answered (Y/N).
7. ``Resolved_status``: Whether the issue was resolved (Y/N).
8. ``Speed_of_Answer_in_Seconds``: Time taken to answer in seconds.
9. ``Talk_Duration``: Average call duration.
10. ``Satisfaction_Rating``: Customer satisfaction rating (1-5).

## SQL Techniques Used
1. Common Table Expression (CTEs)
2. Window Functions
3. Subqueries
4. Join Tables
5. Date and Time Manipulation
6. Aggregate Functions

## Business Questions
1. What is the average resolution time for each topic and how does it compare to the overall average resolution? [Solution1](#q1-what-is-the-average-resolution-time-for-each-topic-and-how-does-it-compare-to-the-overall-average-resolution)
2. How to rank the agents with the best performance based on multiple criteria: resolution rate, answer rate, number of calls, average satisfaction? [Solution2](#q2-how-to-rank-the-agents-with-the-best-performance-based-on-multiple-criteria-resolution-rate-answer-rate-number-of-calls-average-satisfaction)
3. Which topics have the highest number of unresolved cases, and does the unresolved case affect the satisfaction rating? [Solution3](#q3-which-topics-have-the-highest-number-of-unresolved-cases-and-does-the-unresolved-case-affect-the-satisfaction-rating) 
4. What are the peak days for incoming calls? [Solution4](#q4-what-are-the-peak-days-for-incoming-calls)
5. Does the speed of answering the call affect the satisfaction rating? [Solution5](#q5-does-the-speed-of-answering-the-call-affect-the-satisfaction-rating)

## Solution
### Q1. What is the average resolution time for each topic and how does it compare to the overall average resolution?
```sql
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
```
topic            |avg_resolution_time|overall_avg_resolution|resolution_diff_in_second|resolution_comparison|
-----------------|-------------------|----------------------|-------------------------|---------------------|
Payment related  |             216.61|                225.18|                     8.57|Faster than Average  |
Technical Support|             225.03|                225.18|                     0.15|Faster than Average  |
Contract related |             226.10|                225.18|                     0.92|Slower than Average  |
Streaming        |             228.11|                225.18|                     2.93|Slower than Average  |
Admin Support    |             230.02|                225.18|                     4.84|Slower than Average  |

#### Insight Q1
The overall average of resolution or completion time is 225.18 seconds or 3.75 minutes. The result reveals that **topics related to contract related, streaming, and admin support take longer time for agents to solve.** This indicates potential areas for improvement in these categories, especially for **admin support topic which takes the longest time** (4.84 second slower than overall average).

### Q2. How to rank the agents with the best performance based on multiple criteria: resolution rate, answer rate, number of calls, average satisfaction?
```sql
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
```
agent  |total_calls|answered_rate|resolution_rate|avg_satisfaction_rating|performance_rank|
-------|-----------|-------------|---------------|-----------------------|----------------|
Greg   |        502|        80.45|          90.64|                   3.40|               1|
Jim    |        536|        80.48|          90.49|                   3.39|               2|
Diane  |        501|        79.15|          90.22|                   3.41|               3|
Joe    |        484|        81.62|          90.08|                   3.33|               4|
Dan    |        523|        82.62|          90.06|                   3.45|               5|
Martha |        514|        80.56|          89.69|                   3.47|               6|
Becky  |        517|        81.93|          89.36|                   3.37|               7|
Stewart|        477|        81.96|          88.89|                   3.40|               8|

#### Insight Q2
- The agent performance ranking show that Greg, Jim, and Diane are the top 3 performing agents. They  consistently maintaining balanced resolution rate, answered rate and satisfaction rating. This demonstrates their expertise on handling calls effectively.
- Stewart is the lowest ranked agent. He has relatively weaker performance across 4 metrics.
- Martha has highest satisfaction ratings but lower resolutions rates. This shows her strength in maintaining positive interactions with customers, but it is better to improve the resolution rate as the goal of call center agents is to solve customers issues.

### Q3. Which topics have the highest number of unresolved cases, and does the unresolved case affect the satisfaction rating?
```sql
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
 
```
topic            |unresolved_percentage|avg_satisfaction_rating|
-----------------|---------------------|-----------------------|
Technical Support|                 8.57|                  3.415|
Admin Support    |                 9.06|                  3.426|
Contract related |                10.14|                  3.378|
Payment related  |                10.88|                  3.396|
Streaming        |                11.57|                  3.403|
### Q4. What are the peak days for incoming calls?
```sql
select 
    DAYOFWEEK(Date) as day_of_week, 
    COUNT(*) as Total_Calls
from data_call_center 
group by day_of_week
order by day_of_week;
```

| day_of_week | Total_Calls |
|-------------|-------------|
|           1 |         716 |
|           2 |         770 |
|           3 |         675 |
|           4 |         679 |
|           5 |         712 |
|           6 |         680 |
|           7 |         768 |

	  
### Q5. Does the speed of answering the call affect the satisfaction rating? 
```sql
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
```
speed_status|total_calls|avg_satisfaction_rating|
------------|-----------|-----------------------|
Moderate    |       1045|                 3.3694|
Slow        |       1026|                 3.3840|
Fast        |        720|                 3.4278|
Very Slow   |       1263|                 3.4339|
