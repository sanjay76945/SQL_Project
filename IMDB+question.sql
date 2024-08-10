USE imdb;

-- 1. Assessed Data Structure:

-- Objective: Determine the total number of rows in key tables of the schema.
-- SQL Query:

SELECT COUNT(*) AS total_movie_rows FROM movie;
SELECT COUNT(*) AS total_genre_rows FROM genre;
SELECT COUNT(*) AS total_dm_rows FROM director_mapping;
SELECT COUNT(*) AS total_rm_rows FROM role_mapping;
SELECT COUNT(*) AS total_name_rows FROM names;
SELECT COUNT(*) AS total_ratings_rows FROM ratings;


-- 2. Data Quality Check:

-- Objective: Identify columns in the movie table with null values to assess data completeness.
-- SQL Query:


SELECT
    COUNT(*) - COUNT(id) AS id_nulls,
    COUNT(*) - COUNT(title) AS title_nulls,
    COUNT(*) - COUNT(year) AS year_nulls,
    COUNT(*) - COUNT(date_published) AS date_published_nulls,
    COUNT(*) - COUNT(duration) AS duration_nulls,
    COUNT(*) - COUNT(country) AS country_nulls,
    COUNT(*) - COUNT(worlwide_gross_income) AS worldwide_gross_income_nulls,
    COUNT(*) - COUNT(languages) AS langusges_nulls,
    COUNT(*) - COUNT(production_company) AS production_company_nulls
FROM movie;



-- 3. Trend Analysis:

-- Objective: Analyze the number of movies released each year and identify month-wise trends.
-- SQL Query:



SELECT
    year,
    COUNT(*) AS number_of_movies
FROM movie
GROUP BY year
ORDER BY year;

SELECT
    MONTH(date_published) AS month_num,
    COUNT(*) AS number_of_movies
FROM movie
WHERE date_published IS NOT NULL
GROUP BY month_num
ORDER BY month_num;




-- The highest number of movies is produced in the month of March.

-- 4. Country-Specific Movie Production:

-- Objective: Find the number of movies produced in the USA or India in the year 2019.
-- SQL Query:


SELECT COUNT(*) AS num_of_movie_in_India_USA
FROM movie
WHERE (lower(country) LIKE '%usa%' OR lower(country) LIKE '%india%') AND year = 2019;


/* USA and India produced more than a thousand movies in the year 2019.
Let’s find out the different genres in the dataset.*/

-- 5. Genre Exploration:

-- Objective: Identify the unique list of genres present in the dataset.
-- SQL Query:


SELECT DISTINCT genre
FROM genre;



-- 6. Top Genre Identification:

-- Objective: Determine which genre had the highest number of movies produced overall.
-- SQL Query:


WITH genre_counts AS (
    SELECT
        genre AS Genre,
        COUNT(movie_id) AS movie_count,
        RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
    FROM genre
    GROUP BY genre
)
SELECT Genre, movie_count
FROM genre_counts
WHERE genre_rank = 1;


-- 7. Single-Genre Movies:

-- Objective: Count the number of movies that belong to only one genre.
-- SQL Query:


WITH movies_with_one_genre AS (
    SELECT movie_id
    FROM genre
    GROUP BY movie_id
    HAVING COUNT(DISTINCT genre) = 1
)
SELECT COUNT(*) AS movies_with_only_one_genre
FROM movies_with_one_genre;



-- 8. Average Movie Duration by Genre:

-- Objective: Calculate the average duration of movies in each genre.
-- SQL Query:



SELECT 
    g.genre AS genre, 
    AVG(m.duration) AS avg_duration
FROM 
    movie m
INNER JOIN 
    genre g ON m.id = g.movie_id
GROUP BY 
    g.genre
ORDER BY 
    avg_duration DESC;



/* Now we know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- 9. Genre Ranking:

-- Objective: Determine the rank of the ‘thriller’ genre among all genres in terms of the number of movies produced.
-- SQL Query:


WITH genre_rank AS (
    SELECT
        genre,
        COUNT(movie_id) AS movie_count,
        RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
    FROM genre
    GROUP BY genre
)
SELECT genre, movie_count, genre_rank
FROM genre_rank
WHERE LOWER(genre) = 'thriller';



/*Thriller movies is in top 3 among all genres in terms of number of movies*/


-- 10. Range Identification in Ratings:

-- Objective: Determine the minimum and maximum values for key columns in the ratings table.
-- SQL Query:



SELECT
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM ratings;


    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/


-- 11. Top 10 Movies by Average Rating:

-- Objective: Identify the top 10 movies based on average rating.
-- SQL Query:



WITH movie_rank AS (
    SELECT
        m.title,
		r.avg_rating,
        ROW_NUMBER() OVER (ORDER BY r.avg_rating DESC) AS movie_rank
    FROM movie AS m
    LEFT JOIN ratings AS r 
    ON m.id = r.movie_id
)
SELECT title, avg_rating, movie_rank
FROM movie_rank
WHERE movie_rank<=10;



-- 12. Median Rating Summary:

-- Objective: Summarize the ratings table by counting the number of movies for each median rating.
-- SQL Query:



SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY COUNT(movie_id);




/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- 13. Top Production Companies:

-- Objective: Identify the production house that produced the most number of hit movies (average rating > 8).
-- SQL Query:



WITH hit_movies AS (
    SELECT
        m.production_company,
        COUNT(m.id) AS movie_count,
        RANK() OVER (ORDER BY COUNT(m.id) DESC) AS prod_company_rank
    FROM movie AS m
    LEFT JOIN ratings AS r ON m.id = r.movie_id
    WHERE r.avg_rating > 8
        AND m.production_company IS NOT NULL
    GROUP BY m.production_company
)
SELECT *
FROM hit_movies
WHERE prod_company_rank = 1;




-- 14. Genre-Specific Movie Counts:

-- Objective: Count the number of movies released in each genre during March 2017 in the USA that had more than 1,000 votes.
-- SQL Query:




SELECT
    g.genre,
    COUNT(*) AS movie_count
FROM
    movie m
JOIN
    genre g ON m.id = g.movie_id
JOIN
    ratings r ON m.id = r.movie_id
WHERE
    LOWER(m.country) LIKE '%usa%'
    AND m.date_published BETWEEN '2017-03-01' AND '2017-03-31'
    AND r.total_votes > 1000
GROUP BY
    g.genre
ORDER BY
    movie_count DESC;
    



-- 15. Movies Starting with 'The':

-- Objective: Find movies of each genre that start with the word ‘The’ and have an average rating greater than 8.
-- SQL Query:



SELECT
   m.title,
    r.avg_rating,
    g.genre
FROM
    movie m
JOIN
    genre g ON m.id = g.movie_id
JOIN
    ratings r ON m.id = r.movie_id
WHERE
     m.title LIKE 'The%'
     AND r.avg_rating > 8;







-- 16. Median Rating Insights:

-- Objective: Count the number of movies released between 1 April 2018 and 1 April 2019 that received a median rating of 8.
-- SQL Query:



SELECT 
      COUNT(*) AS median_rating_eight_movie_count
FROM movie AS m
JOIN ratings AS r
ON m.id = r.movie_id
WHERE m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
	AND r.median_rating = 8;





-- 17. Comparative Analysis: German vs. Italian Movies:

-- Objective: Determine whether German movies receive more votes than Italian movies by comparing total votes.
-- SQL Query:



WITH vote_summary AS (
    SELECT 
        SUM(CASE WHEN LOWER(m.languages) LIKE '%german%' THEN 1 ELSE 0 END) AS german_movie_count,
        SUM(CASE WHEN LOWER(m.languages) LIKE '%italian%' THEN 1 ELSE 0 END) AS italian_movie_count,
        SUM(CASE WHEN LOWER(m.languages) LIKE '%german%' THEN r.total_votes ELSE 0 END) AS german_movie_votes,
        SUM(CASE WHEN LOWER(m.languages) LIKE '%italian%' THEN r.total_votes ELSE 0 END) AS italian_movie_votes
    FROM 
        movie AS m
    INNER JOIN 
        ratings AS r ON m.id = r.movie_id
)

SELECT 
    ROUND( german_movie_votes/german_movie_count,2
    ) AS german_votes_per_movie,
    ROUND(
        italian_movie_votes/italian_movie_count, 2
    ) AS italian_votes_per_movie
FROM 
    vote_summary;




-- Answer is Yes

/* Now that we have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- 18. Identification of Null Values in the names Table:

-- Objective: Determine which columns in the names table contain null values and count them.
-- SQL Query:


SELECT
    COUNT(*) - COUNT(id) AS id_nulls,
    COUNT(*) - COUNT(name) AS name_nulls,
    COUNT(*) - COUNT(height) AS height_nulls,
    COUNT(*) - COUNT(date_of_birth) AS date_of_birth_nulls,
    COUNT(*) - COUNT(known_for_movies) AS known_for_movies_nulls
FROM names;




/* There are no Null value in the Table 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/


-- 19. Top Directors in Top Genres:

-- Objective: Identify the top three directors in the top three genres whose movies have an average rating greater than 8.
-- SQL Query:


WITH TopGenres AS (
    SELECT 
        g.genre
    FROM 
        genre AS g
        INNER JOIN ratings r ON g.movie_id = r.movie_id
    WHERE 
        r.avg_rating > 8
    GROUP BY 
        g.genre
    ORDER BY 
        COUNT(r.movie_id) DESC
    LIMIT 3
)
SELECT 
    n.name AS director_name,
    COUNT(dm.movie_id) AS movie_count
FROM 
    director_mapping AS dm
    INNER JOIN names n ON dm.name_id = n.id
    INNER JOIN movie m ON dm.movie_id = m.id
    INNER JOIN genre g ON m.id = g.movie_id
    INNER JOIN ratings r ON m.id = r.movie_id
WHERE 
    r.avg_rating > 8
    AND g.genre IN (SELECT genre FROM TopGenres)
GROUP BY 
    n.name
ORDER BY 
    movie_count DESC
LIMIT 3;





/* James Mangold can be hired as the director for RSVP's next project. His movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/


-- 20. Top Actors Based on Median Rating:

-- Objective: Find the top two actors whose movies have a median rating of 8 or higher.
-- SQL Query:



SELECT 
      n.name AS actor_name,
      COUNT(r.movie_id) AS movie_count
FROM 
    names AS n
    INNER JOIN role_mapping AS rm
    ON n.id = rm.name_id
    INNER JOIN ratings AS r
    ON rm.movie_id = r.movie_id
WHERE rm.category = 'actor' AND r.median_rating >= 8
GROUP BY n.name
ORDER BY COUNT(r.movie_id) DESC
LIMIT 2;




-- 21. Top Production Houses by Vote Count:

-- Objective: Identify the top three production houses based on the number of votes received by their movies.
-- SQL Query:


WITH top_production_house AS
(
SELECT 
      m.production_company AS production_company,
      SUM(r.total_votes) AS total_votes,
      COUNT(m.id) AS movie_count,
      ROW_NUMBER() OVER(ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank 
FROM
	 movie AS m
     INNER JOIN ratings AS r
     ON m.id = r.movie_id
GROUP BY m.production_company

)

SELECT production_company,
       ROUND(total_votes/movie_count,2) AS vote_count,
       prod_comp_rank
FROM top_production_house
LIMIT 3;



/*Yes Marvel Studios rules the movie world.*/

-- 22. Ranking Indian Actors by Average Rating:

-- Objective: Rank actors with movies released in India based on their average ratings. The actor must have acted in at least five Indian movies.
-- SQL Query:


WITH actor_ratings AS
(
 SELECT 
       n.name as actor_name,
       SUM(r.total_votes) AS total_votes,
	   COUNT(m.id) as movie_count,
       ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) as actor_avg_rating
FROM 
    names as n
INNER JOIN 
	role_mapping as a
ON 
    n.id = a.name_id
INNER JOIN 
    movie as m
ON 
    a.movie_id = m.id
INNER JOIN 
	ratings as r
ON 
    m.id = r.movie_id
WHERE 
    category = 'actor' AND LOWER(country) LIKE '%india%'
GROUP BY 
	actor_name
)
select *, rank() over (order by actor_avg_rating DESC, total_votes DESC) as actor_rank
FROM actor_ratings
WHERE movie_count>=5;




-- Top actor is Vijay Sethupathi

-- 23. Top Actresses in Hindi Movies:

-- Objective: Identify the top five actresses in Hindi movies released in India based on their average ratings. The actresses must have acted in at least three Indian movies.
-- SQL Query:


WITH actor_ratings AS
(
 SELECT 
       n.name as actress_name,
       SUM(r.total_votes) AS total_votes,
	   COUNT(m.id) as movie_count,
       ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) as actor_avg_rating
FROM 
    names as n
INNER JOIN 
	role_mapping as a
ON 
    n.id = a.name_id
INNER JOIN 
    movie as m
ON 
    a.movie_id = m.id
INNER JOIN 
	ratings as r
ON 
    m.id = r.movie_id
WHERE 
    category = 'actress' AND LOWER(languages) LIKE '%hindi%' AND LOWER(country) LIKE '%india%'
GROUP BY 
	actress_name
)
select *, rank() over (order by actor_avg_rating DESC, total_votes DESC) as actor_rank
FROM actor_ratings
WHERE movie_count>=3
LIMIT 5;






/* Taapsee Pannu tops with average rating 7.74.*/


-- 24. Classification of Thriller Movies:

-- Objective: Categorize thriller movies based on their average ratings into defined categories: Superhit, Hit, One-time-watch, and Flop.
-- Categories:
-- Superhit Movies: Rating > 8
-- Hit Movies: Rating between 7 and 8
-- One-time-watch Movies: Rating between 5 and 7
-- Flop Movies: Rating < 5

-- SQL Query:


SELECT
    m.title,
    m.year,
    r.avg_rating,
    g.genre,
    CASE
        WHEN r.avg_rating > 8 THEN 'Superhit movies'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        WHEN r.avg_rating < 5 THEN 'Flop movies'
    END AS category
FROM
    movie m
JOIN
    genre g ON m.id = g.movie_id
JOIN
    ratings r ON m.id = r.movie_id
WHERE
    g.genre = 'Thriller';


-- 25. Genre-wise running total and moving average

-- Objective: The genre-wise running total and moving average of the average movie duration.
-- SQL Query:


WITH genre_summary AS
(
SELECT 
    genre,
    ROUND(AVG(duration),2) AS avg_duration
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
                ON g.movie_id = m.id
GROUP BY genre
)
SELECT *,
        SUM(avg_duration) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
    AVG(avg_duration) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING) AS moving_avg_duration
FROM
        genre_summary;






-- 26. Let us find top 5 movies of each year with top 3 genres.

-- Objective: The five highest-grossing movies of each year that belong to the top three genres.
-- SQL Query:




WITH top_genres AS
(
SELECT 
    genre,
    COUNT(m.id) AS movie_count,
        RANK () OVER (ORDER BY COUNT(m.id) DESC) AS genre_rank
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
                ON g.movie_id = m.id
GROUP BY genre
)
,
top_grossing AS
(
SELECT 
    g.genre,
        year,
        m.title as movie_name,
    worlwide_gross_income,
    RANK() OVER (PARTITION BY g.genre, year
                                        ORDER BY CONVERT(REPLACE(TRIM(worlwide_gross_income), "$ ",""), UNSIGNED INT) DESC) AS movie_rank
FROM
movie AS m
        INNER JOIN
genre AS g
        ON g.movie_id = m.id
WHERE g.genre IN (SELECT DISTINCT genre FROM top_genres WHERE genre_rank<=3)
)
SELECT * 
FROM
        top_grossing
WHERE movie_rank<=5;




-- 27. Let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.

-- Objective: The top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies.
-- SQL Query:



SELECT 
      m.production_company AS production_company,
      COUNT(r.movie_id) AS movie_count,
      ROW_NUMBER() OVER(ORDER BY COUNT(r.movie_id) DESC) AS prod_comp_rank
FROM 
	 movie AS m
     INNER JOIN ratings AS r
     ON m.id = r.movie_id
WHERE m.production_company IS NOT NULL AND r.median_rating >= 8 AND m.languages LIKE '%,%'
GROUP BY m.production_company
LIMIT 2;


-- 28. Top three actresses in the drama genre based on the number of super hit movies.

-- Objective: The top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre.
-- SQL Query:


WITH actor_ratings AS
(
 SELECT 
       n.name as actress_name,
       SUM(r.total_votes) AS total_votes,
	   COUNT(m.id) as movie_count,
       ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) as actor_avg_rating,
       rank() over (order by COUNT(m.id) DESC) as actress_rank
FROM 
    names as n
INNER JOIN 
	role_mapping as a
ON 
    n.id = a.name_id
INNER JOIN 
    movie as m
ON 
    a.movie_id = m.id
INNER JOIN 
	ratings as r
ON 
    m.id = r.movie_id
INNER JOIN 
	genre as g
ON
   r.movie_id = g.movie_id
WHERE 
    category = 'actress' AND r.avg_rating>8 AND g.genre = 'Drama'
GROUP BY 
	actress_name
)
select *
FROM actor_ratings
LIMIT 3;



-- 29. Detailed information for the top nine directors based on the number of movies directed.


-- Objective: Get the following details for top 9 directors (based on number of movies)
/*Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations*/

-- SQL Query:



WITH top_directors AS
(
SELECT 
        n.id as director_id,
    n.name as director_name,
        COUNT(m.id) AS movie_count,
    RANK() OVER (ORDER BY COUNT(m.id) DESC) as director_rank
FROM
        names AS n
                INNER JOIN
        director_mapping AS d
                ON n.id=d.name_id
                        INNER JOIN
        movie AS m
                        ON d.movie_id = m.id
GROUP BY n.id
),
movie_summary AS
(
SELECT
        n.id as director_id,
    n.name as director_name,
    m.id AS movie_id,
    m.date_published,
        r.avg_rating,
    r.total_votes,
    m.duration,
    LEAD(date_published) OVER (PARTITION BY n.id ORDER BY m.date_published) AS next_date_published,
    DATEDIFF(LEAD(date_published) OVER (PARTITION BY n.id ORDER BY m.date_published),date_published) AS inter_movie_days
FROM
        names AS n
                INNER JOIN
        director_mapping AS d
                ON n.id=d.name_id
                        INNER JOIN
        movie AS m
                        ON d.movie_id = m.id
                                INNER JOIN
            ratings AS r
                                ON m.id=r.movie_id
WHERE n.id IN (SELECT director_id FROM top_directors WHERE director_rank<=9)
)
SELECT 
        director_id,
        director_name,
        COUNT(DISTINCT movie_id) as number_of_movies,
        ROUND(AVG(inter_movie_days),0) AS avg_inter_movie_days,
        ROUND(
        SUM(avg_rating*total_votes)
        /
        SUM(total_votes)
                ,2) AS avg_rating,
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration
FROM 
movie_summary
GROUP BY director_id
ORDER BY number_of_movies DESC, avg_rating DESC;



