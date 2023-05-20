/* Q1. Find the highest number of parking spots across all properties */

select max(parking_spots) as max_parking_spots 
    from airbnb_dim_property;

/* Q2. Among videos with duration > 5 min, how many unique users watched per video? 
Output the video_id and count. Order by number of distinct viewers desc. */

SELECT video_id, COUNT(DISTINCT user_id) AS number_of_distinct_users
FROM youtube_reactions
    WHERE video_id IN (SELECT video_id FROM youtube_videos WHERE duration_sec > 300)
GROUP BY video_id
ORDER BY 2 desc;

/* Q3. What is the average time in days it takes for a user to enroll in prime after creating an account?
Ignore users who never joined prime. Round to 2 decimal places. */

select round(avg(datediff(prime_joined_dt, joined_dt)), 2) as avg_days_to_join
from amazon_users
where prime_member = 1

SELECT avg(timestampdiff(day, joined_dt, prime_joined_dt)) avg_days_to_join
FROM amazon_users
WHERE prime_member = 1;

/* Q4. What is the average video duration in minutes of monetized videos and non-monetized videos
among users in UK, Australia, and US? Output the monetization type and average duration in minutes.
 Round duration to the 2 decimal points.

Expected Output:
Your answer should match this structure exactly. Keep in mind SQL sorting, grouping, & rounding when answering.
is_monetized	avg_video_duration
0	5.28
1	5.75

*/
. 

SELECT a.is_monetized, round(avg(a.duration_sec) / 60, 2)
FROM youtube_videos a
WHERE user_id IN (
  SELECT DISTINCT(user_id)
  FROM youtube_users
  WHERE country in (
  'UK', 'Australia', 'US'
  )
)
GROUP BY is_monetized

--------

SELECT is_monetized, round(cast(avg(duration_sec) as double) /60, 2) avg_video_duration
FROM youtube_videos
JOIN (SELECT user_id FROM youtube_users WHERE country IN ('UK', 'Australia', 'US')) u
USING (user_id)
GROUP BY is_monetized;

/*Q5. Find the top 5 largest properties at AirBnB (3000+ sqft). Ignore ties, return exactly 5 order by property id asc.

Expected Output:
Your answer should match this structure exactly. Keep in mind SQL sorting, grouping, & rounding when answering.
property_id
2
3
4
15
25
*/
 
select property_id 
from airbnb_dim_property 
where total_sqft = '3000+' 
order by property_id ASC 
limit 5

/* Q6. In each country, what is the percentage of users who enrolled on prime within 5 days 
(inclusive) after joining Amazon? Round to 2 decimal places and order the output by country asc.

Expected Output:

Your answer should match this structure exactly. Keep in mind SQL sorting, grouping, & rounding when answering.
country	percentage
Australia	25
Brazil	7.69
China	14.29
France	20
UK	14.29
US	7.14
*/

SELECT country, 
    round(avg(joined_prime_within_5_days) * 100, 2) as percentage
FROM (
    SELECT country,
        CASE 
            WHEN timestampdiff(day, joined_dt, prime_joined_dt) <= 5
            THEN 1 
            ELSE 0
        END joined_prime_within_5_days,
        joined_dt,
        prime_joined_dt
    FROM amazon_users
) prime_users
GROUP BY country
ORDER BY country;

/* Q7. How many transactions have missing payment method?

Expected Output:

Your answer should match this structure exactly. Keep in mind SQL sorting, grouping, & rounding when answering.
num_missing
19
*/ 

SELECT count(transaction_id) as num_missing
FROM appstore_transactions	
WHERE payment_method is NULL

-----

SELECT count(*) num_missing
FROM appstore_transactions
WHERE payment_method IS NULL;

/* Q8. Find the top poster(s) on Facebook and count how many of each post type they had. 
Please consider ties and return all users if tie exists. Order answer by creator asc and post type asc.

Expected Output:

Your answer should match this structure exactly. Keep in mind SQL sorting, grouping, & rounding when answering.
creator	post_type	total_posts
2	ad	1
2	poll	1
2	post	1
2	video	2
8	ad	1
8	poll	2
8	post	2

*/

with posts_rpt as ( 
    select 
     user_id 
    ,rank() over(order by count(*) desc) rnk 
    from fb_posts 
    group by 1 
) 
Select 
 user_id creator
,post_type
,count(*) total_posts 
from fb_posts 
where user_id in (select user_id from posts_rpt where rnk = 1) 
group by 1, 2 
order by 1, 2

/* Q9. What is the global click through rate (CTR) of advertisement and non-advertisement link types?
CTR = # of Clicked / # of Viewed in this scenario. Round conversion to the 2 decimal points and order by advertisement asc.

Expected Output:

Your answer should match this structure exactly. Keep in mind SQL sorting, grouping, & rounding when answering.
advertisement	conversion
0	0.41
1	0.5

*/

SELECT advertisement, 
    round(SUM(CASE WHEN event_type = 'clicked' THEN 1 ELSE 0 END) 
    / SUM(CASE WHEN event_type = 'viewed' THEN 1 ELSE 0 END), 2) conversion
FROM google_search_activity
GROUP BY advertisement
order by 1 asc;

/* Q10. Your manager wants a cleaned up report with only Low, Med, High as 
growth types broken down by total count. Help him clean up the data with 
just those values and when you return your answer make sure its sorted by total desc.

Expected Output:

Your answer should match this structure exactly. Keep in mind SQL sorting, grouping, & rounding when answering.
growth_typecleaned	total
Low	31
High	13
Med	6


*/ 

SELECT
CASE
  WHEN growth_type = 'Loww' THEN 'Low'
  WHEN growth_type = 'low' THEN 'Low'
  WHEN growth_type = 'Hgh' THEN 'High'
  ELSE growth_type
END as growth_typecleaned, count(*) as total
FROM messy_data
GROUP BY growth_typecleaned

/* Q11.  Find the total number of luxury properties that AirBnb. */

SELECT COUNT(property_type) as total_luxury_properties
FROM airbnb_dim_property
WHERE property_type = 'Luxury'

------------

select count(*) as total_luxury_properties 
from airbnb_dim_property 
where property_type = 'Luxury';

/* Q12. Find the total number of impressions each ad received. Sort answer by impressions desc and ad asc.
*/

SELECT ad_name, COUNT(ad_exp_id) as ad_impressions
FROM ads_actions
GROUP BY ad_name
ORDER BY 2 DESC, 1 ASC;

------------

select
 ad_name
,count(*) ad_impressions
from ads_actions
group by 1
order by 2 desc, 1 asc

/* Q13.   */

WITH top_property as (
SELECT property_id
,RANK() OVER(ORDER BY SUM(num_of_nights) DESC) rnk
FROM airbnb_fct_rentals
GROUP BY 1
  )
SELECT property_id from top_property WHERE rnk = 1

-------------

with property_rpt as (
    SELECT property_id
    ,count(*) rentals
    ,rank() over(order by count(*) desc) rnk
    from airbnb_fct_rentals r
    group by 1
)
select property_id
from property_rpt
where rnk = 1
order by 1 asc

/*Q14. Among all the events after April 1, 2022, what is the total count as well as 
the most recent datetime of each event type? Order the output in the alphabetical order of event_type.
*/

SELECT event_type, COUNT(*) as ride_counts
,date(max(creation_dt)) event_datetime
FROM google_maps_actions
WHERE creation_dt > '2022-04-01'
GROUP BY 1
ORDER BY 1 ASC;


/* Q15. Find the percent of users who are permanently banned. Round your answer to 2 decimals.
*/

SELECT
ROUND(COUNT(CASE WHEN is_temporary = 0 THEN 1 ELSE NULL END) / 
  COUNT(*) * 100, 2) permanent_banned_prcnt
FROM banned_users


/* Q16. You are on the Digital Marketing team at Google. You are asked to find 
what is the click-through-rate, (CTR), per each website type? CTR = # of Clicked / # of Viewed. 
Be sure to use the 'event_type' column for this one and not the 'conversion' column, 
our data engineer said theres some bugs in this one. Round to 2 decimal places. 
Output answer sorted by type asc.
*/

SELECT A.type, 
ROUND(SUM(CASE WHEN A.event_type = 'clicked' THEN 1 ELSE 0 END) /
  SUM(CASE WHEN A.event_type = 'viewed' THEN 1 ELSE 0 END), 2 )conversion
FROM
(SELECT a.*, b.type
FROM google_search_activity a
JOIN google_search_websites b
ON a.website_id = b.website_id) A
GROUP BY A.type
ORDER BY 1 ASC;

-----------------

WITH website_type AS (
    SELECT type, event_type
    FROM google_search_websites
    JOIN google_search_activity
    USING (website_id)
)
SELECT type, 
    round(sum(case when event_type = 'clicked' then 1 else 0 end) 
    / sum(case when event_type = 'viewed' then 1 else 0 end), 2) conversion
FROM website_type
GROUP BY type
ORDER BY type;

