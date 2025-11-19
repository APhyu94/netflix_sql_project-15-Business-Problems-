-- netflix project

CREATE TABLE netflix
(
	show_id	VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(210),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
)

select * from netflix;

-- Convert date_added to Real DATE
ALTER TABLE netflix
ADD COLUMN date_added_clean DATE;

UPDATE netflix
SET date_added_clean = TO_DATE(date_added, 'Month DD, YYYY');


-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
SELECT 
	type, 
	COUNT(*) AS Number_of_Count
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows

SELECT
	type,
	rating,
	Total_Count
FROM(
	SELECT
		type,
		rating,
		COUNT(*) AS Total_Count,
		ROW_NUMBER() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS RN
	FROM netflix
	GROUP BY type, rating
) AS t1
WHERE RN = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix
WHERE type = 'Movie'
AND release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
WITH country_split AS(
SELECT
	TRIM(unnested_country) AS country
FROM netflix,
LATERAL UNNEST(string_to_array(country, ',')) AS unnested_country
)

SELECT 	
	country,
	COUNT(*) AS total_titles
FROM country_split
GROUP BY country
ORDER BY total_titles DESC
LIMIT 5;


-- 5. Identify the longest movie
SELECT
	title,
	SPLIT_PART(duration, ' ', 1) :: INT AS minutes
FROM netflix
WHERE type = 'Movie'
AND duration IS NOT NULL
ORDER BY minutes DESC
LIMIT 1;


-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE date_added_clean >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
SELECT 
	title,
	duration,
	CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS seasons
FROM netflix
WHERE type = 'TV Show'
AND duration LIKE '%Season%'
AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;

-- 9. Count the number of content items in each genre
WITH genre_split AS(
	SELECT
		TRIM(unnest_genre) AS genre
	FROM netflix,
	LATERAL UNNEST(string_to_array(listed_in, ',')) AS unnest_genre
)

SELECT
	genre,
	COUNT(*) AS Number_of_content
FROM genre_split
WHERE genre <> ''
GROUP BY genre
ORDER BY COUNT(*) DESC;

-- 10.Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


select * from netflix

-- 11. List all movies that are documentaries
SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%';


-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix
WHERE casts LIKE '%Salman Khan%'
	AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;

	
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT
	UNNEST(string_to_array(casts, ',')) AS actor,
	COUNT(*) AS number_of_movies
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT
	type,
	CASE
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END AS content_category,
	COUNT(*) AS number_of_items
FROM netflix
GROUP BY 1,2
ORDER BY 1;