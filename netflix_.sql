-- SCHEMAS of Netflix

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(100),
	description VARCHAR(550)
);

SELECT * FROM netflix;

Select 
count(*) as total_content
from netflix;

select 
distinct type
from netflix;




-- 1. Count the number of Movies vs TV Shows

select 
type,
count(*) as total_count
from netflix
group by type

-- 2. Find the most common rating for movies and TV shows

Select 
type,
rating
from
(
Select
type,
Rating,
count(*),
rank() over(partition by type order by count(*) DESC) as ranking
from netflix
group by 1, 2
) as t1
where ranking =1

-- 3. List all movies released in a specific year (e.g., 2020)

select *
from netflix
where type = 'Movie' And release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix

	SELECT 
		UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
		COUNT(Show_id) as total_content
	FROM netflix
	GROUP BY 1
ORDER BY total_content DESC
LIMIT 5

-- 5. Identify the longest movie

select * from netflix
where type = 'Movie' AND duration = (select max(duration) from netflix)

-- 6. Find content added in the last 5 years

select * 
from netflix
where To_Date(date_added, 'Month-DD-YYYY') >= current_date - Interval '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select *
from netflix
where director ilike '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 seasons

select *

from netflix
where type = 'TV Show' and split_part(duration, ' ', 1)::INT > 5

-- 9. Count the number of content items in each genre

select 
unnest(string_to_array(listed_in, ',')) as genre,
count(show_id) 
from netflix
group by 1


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

-- 11. List all movies that are documentaries

select * from netflix
where listed_in ilike '%Documentaries%'

-- 12. Find all content without a director

select * from netflix
where director Is null

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select * from netflix
where Casts ilike '%salman khan%'
AND release_year > extract(year from current_date) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India

select 
uNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
from netflix

where country = 'India'
group by 1
order by 2 DESC
limit 10

-- Question 15:
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2