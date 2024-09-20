CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL 

SELECT * FROM appleStore_description2

UNION ALL 

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

**EXPLORATORY DATA ANALYSIS

-- check the number of unique apps in both tablesAppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore 

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined

-- check missing values in key fields

SELECT COUNT (*) AS MissingValues
FROM AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS null 

SELECT COUNT (*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc IS null

-- Find out the number of apps per genres

SELECT prime_genre, COUNT(*) as NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

--Get an overview of the apps' rating 

SELECT min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
       avg (user_rating) AS AvgRating
FROM AppleStore

**DATA ANALYSIS**

--Determine whether paid apps have a higher rating than free apps 

SELECT CASE
			WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
       END AS App_Type,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

--Check if apps with more supported languages have higher ratings

SELECT CASE 
			WHEN lang_num < 10 THEN '10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
       END AS language_bucket,
       avg(user_rating) AS Avg_Rating
FROM AppleStore 
GROUP BY language_bucket 
ORDER BY Avg_Rating DESC

--Check genres with low rating

SELECT prime_genre,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10

--Check if there is correlation between the length of the app descrption and the user rating

SELECT CASE
           WHEN length (b.app_desc) <500 THEN 'Short'
           WHEN length (b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
           ELSE 'Long'
       End AS description_length_bucket,
       avg(a.user_rating) AS average_rating
       
FROM
	AppleStore AS A 
JOIN 
	appleStore_description_combined AS b 
ON
	a.id = b.id 
GROUP BY description_length_bucket
ORDER BY average_rating DESC

--Check the app top-rated apps for each genre

SELECT 
	prime_genre,
    track_name,
    user_rating
FROM (
      SELECT
      prime_genre,
      track_name,
      user_rating,
      RANK() OVER (PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
 	  FROM
  	  appleStore
    ) AS a
WHERE 
a.rank = 1
  	