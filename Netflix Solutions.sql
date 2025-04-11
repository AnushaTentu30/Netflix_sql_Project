-- Netflix Project

Create Database Netflix_db;

--CREATE TABLE
Drop table if exists Netflix;
Create Table Netflix
(
	show_id	varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(208),
	casts varchar(1000),
	country	varchar(150),
	date_added varchar(50),	
	release_year INT,	
	rating varchar(10),
	duration varchar(15),	
	listed_in varchar(100),	
	description varchar(250)
);

--DATA ANALYSIS
SELECT * from Netflix;


SELECT
    count(*) as total_content 
from Netflix;


SELECT
   Distinct type
from Netflix;

-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

SELECT
	type,
	COUNT(*) as total_content
From Netflix
group by type;

--2. Find the most common rating for movies and TV shows

SELECT
    type,
	rating
from
(
		SELECT
		type,
		rating,
		COUNT(*) as total_content,
		rank() over(partition by type order by COUNT(*) desc) as ranks
	From Netflix
	group by 1,2
) as t1
WHERE ranks=1;

--3. List all movies released in a specific year (e.g., 2020)

SELECT * from Netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix

SELECT
	UNNEST(STRING_TO_ARRAY(Country, ',')) as new_country,
	COUNT(show_id) as total_content
from Netflix
Group by new_country 
order by total_content desc
limit 5;

--5. Identify the longest movie

SELECT * FROM Netflix
WHERE
	type = 'Movie'
	AND
	duration = (SELECT max(duration) from netflix);

--6. Find content added in the last 5 years

SELECT
	*
FROM Netflix
WHERE
	TO_Date(date_added, 'Month DD,YYYY') >= CURRENT_DATE - Interval '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * 
FROM netflix
WHERE 
	director ILIKE '%Rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons

SELECT 
	*
	--SPLIT_PART(duration, ' ', 1) as seasons [SPLIT_PART(string, delimiter, position)]
FROM Netflix
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5;


--9. Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM Netflix
GROUP BY 1;

--10. Find each year and the average numbers of content release in India on Netflix. 
    --return the top 5 years with the highest average content release!
	  -- total content 333/972

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 ,2)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

--11. List all movies that are documentaries

SELECT
	*
FROM Netflix
WHERE type ='Movie'
   	  AND
	  listed_in like '%Documentaries%';



--12. Find all content without a director

SELECT * 
FROM Netflix
WHERE director IS NULL;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM 
(
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR 
				 description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2

-- END of project
