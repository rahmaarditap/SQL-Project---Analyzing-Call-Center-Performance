# 📞 [SQL Project] Analyzing Call Center Performance 

## Tables of Contents
- [Introduction](#introduction)
- [Dataset](#dataset)
- [SQL Techniques Used](#sql-techniques-used)
- [Business Questions](#business-questions)

  
## Introduction
This project demonstrates the use of SQL to analyze and optimize call center performance. The dataset includes information about calls, agents, and customer rating. By leveraging advanced SQL queries, this analysis uncovers trends, identifies areas for improvement, and provides actionable insights to enhance overall efficiency and customer satisfaction.
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
3. Which topics have the highest number of unresolved cases? [Solution3](#q3-which-topics-have-the-highest-number-of-unresolved-cases) 
4. What are the peak days for incoming calls? [Solution4]((q4-#what-are-the-peak-days-for-incoming-calls))
5. Does the speed of answering the call affect the satisfaction rating? [Solution5](#q5-does-the-speed-of-answering-the-call-affect-the-satisfaction-rating)
6. Which call topics have the highest and lowest average satisfaction ratings? [Solution6](#q6-which-call-topics-have-the-highest-and-lowest-average-satisfaction-ratings)

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
from resolution_by_topic rt, overall_resolution ovr;
```
topic            |avg_resolution_time|overall_avg_resolution|resolution_diff_in_second|resolution_comparison|
-----------------|-------------------|----------------------|-------------------------|---------------------|
Contract related |             226.10|                225.18|                     0.92|Slower than Average  |
Payment related  |             216.61|                225.18|                     8.57|Faster than Average  |
Admin Support    |             230.02|                225.18|                     4.84|Slower than Average  |
Streaming        |             228.11|                225.18|                     2.93|Slower than Average  |
Technical Support|             225.03|                225.18|                     0.15|Faster than Average  |

### Q2. How to rank the agents with the best performance based on multiple criteria: resolution rate, answer rate, number of calls, average satisfaction?
### Q3. Which topics have the highest number of unresolved cases?
### Q4. What are the peak days for incoming calls?
### Q5. Does the speed of answering the call affect the satisfaction rating? 
### Q6. Which call topics have the highest and lowest average satisfaction ratings? 
