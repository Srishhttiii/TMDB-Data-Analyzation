-- ============================================================
-- TMDB DATA ANALYSIS
-- SQL Data Exploration & Data Quality Validation
-- Dataset: ~9,770 movies from TMDB
-- ============================================================


-- Creating a database for storing and analyzing the TMDB movie dataset.
CREATE DATABASE tmdb_data_analysis;
USE tmdb_data_analysis;


-- Creating the movies table based on the 22 fields provided in the TMDB movies.csv dataset.
CREATE TABLE movies (
    id BIGINT PRIMARY KEY,
    title VARCHAR(500),
    original_title VARCHAR(500),
    overview TEXT,
    release_date DATE,
    runtime INT,
    budget BIGINT,
    revenue BIGINT,
    vote_average DECIMAL(5,3),
    vote_count INT,
    popularity DECIMAL(15,5),
    poster_path TEXT,
    backdrop_path TEXT,
    status VARCHAR(50),
    tagline TEXT,
    homepage TEXT,
    original_language VARCHAR(10),
    adult TINYINT(1),
    video TINYINT(1),
    created_at VARCHAR(40),
    updated_at VARCHAR(40),
    genres TEXT
);


-- Verifying that the movies table has been created successfully.
SHOW TABLES;


-- Inspecting the table structure, column names, data types and primary key definition.
DESCRIBE movies;


-- Checking the initial number of records in the table before importing the CSV data.
SELECT COUNT(*) AS total_movies FROM movies;

-- OUTPUT 
-- total_movies - 0


-- Enabling LOCAL INFILE at the MySQL server level so that CSV files can be loaded from the local machine.
SET GLOBAL local_infile = 1;


-- Verifying that LOCAL INFILE is enabled at the server level.
SHOW GLOBAL VARIABLES LIKE 'local_infile';


-- Verifying that LOCAL INFILE is enabled for the current MySQL session/connection.
SHOW VARIABLES LIKE 'local_infile';


-- Importing the movies.csv dataset into the movies table.
LOAD DATA LOCAL INFILE 'C:/Mac/Home/Documents/TMDB Data Analysis/movies.csv'
INTO TABLE movies
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- OUTPUT
-- Records: 9770
-- Deleted: 0
-- Skipped: 0
-- Warnings: 60 (release_date)


-- Confirming that all movie records were successfully imported into the table.
SELECT COUNT(*) AS total_movies FROM movies;

-- OUTPUT 
-- total_movies - 9770


-- Checking whether any movies have missing release dates.
SELECT COUNT(*) AS missing_dates FROM movies WHERE release_date IS NULL;

-- OUTPUT 
-- missing_dates- 0


-- Inspecting warnings generated during the CSV import, particularly data conversion issues.
SHOW WARNINGS;

-- OUTPUT - (No Warnings)


-- Determining the earliest and latest release dates available in the dataset.
SELECT
    MIN(release_date) AS earliest_release,
    MAX(release_date) AS latest_release
FROM movies;

-- OUTPUT
-- earliest_release - 0000-00-00
-- latest_release - 2028-03-16


-- Disabling MySQL Safe Update Mode to allow the use of UPDATE statement.
SET SQL_SAFE_UPDATES = 0;


-- Replacing invalid '0000-00-00' release dates with NULL.
UPDATE movies SET release_date = NULL WHERE YEAR(release_date) = 0;


-- Rechecking the date range after cleaning invalid release dates.
SELECT
    MIN(release_date) AS earliest_release,
    MAX(release_date) AS latest_release
FROM movies;

-- OUTPUT
-- earliest_release - 1904-05-01
-- latest_release - 2028-03-16


-- Comparing total rows with distinct movie IDs to verify that every movie ID is unique.
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT id) AS unique_ids FROM movies;

-- OUTPUT 
-- total_rows - 9,770
-- unique_ids - 9,770


-- Checking for movies with missing or empty titles.
SELECT
    SUM(title IS NULL OR TRIM(title) = '') AS missing_title,
    SUM(original_title IS NULL OR TRIM(original_title) = '') AS missing_original_title
FROM movies;

-- OUTPUT
-- missing_titles - 0
-- missing_original_title - 0


-- Checking if title and original_title columns are same.
SELECT
    SUM(title = original_title) AS same_titles,
    SUM(title <> original_title) AS different_titles
FROM movies;

-- OUTPUT
-- same_titles - 8064
-- different_titles - 1706


-- Checking duplicate movies.
SELECT
    title,
    release_date,
    COUNT(*) AS occurrences
FROM movies
GROUP BY title, release_date
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- OUTPUT - (No duplicate movies)


-- Checking for missing or unavailable runtime values.
SELECT COUNT(*) AS missing_runtime FROM movies WHERE runtime IS NULL OR runtime = 0;

-- OUTPUT
-- missing_runtime - 439


-- Replacing invalid '0' runtime with NULL.
UPDATE movies SET runtime = NULL WHERE runtime = 0;


-- Rehecking for '0' runtime values.
SELECT COUNT(*) AS missing_runtime FROM movies WHERE runtime = 0;

-- OUTPUT
-- missing_runtime - 0


-- Counting movies where budget information is unavailable.
SELECT COUNT(*) AS unavailable_budget FROM movies WHERE budget = 0;

-- OUTPUT
-- unavailable_budget - 5756


-- Replacing invalid '0' budget with NULL.
UPDATE movies SET budget = NULL WHERE budget = 0;


-- Rehecking for '0' budget values.
SELECT COUNT(*) AS unavailable_budget FROM movies WHERE budget = 0;

-- OUTPUT
-- unavailable_budget - 0


-- Counting movies where revenue information is unavailable.
SELECT COUNT(*) AS unavailable_revenue FROM movies WHERE revenue = 0;

-- OUTPUT
-- unavailable_revenue - 5744


-- Replacing invalid '0' revenue with NULL.
UPDATE movies SET revenue = NULL WHERE revenue = 0;


-- Rehecking for '0' revenue values.
SELECT COUNT(*) AS unavailable_revenue FROM movies WHERE revenue = 0;

-- OUTPUT
-- unavailable_revenue - 0


-- Counting movies with available production budget information.
SELECT COUNT(*) AS movies_with_budget FROM movies WHERE budget > 0;

-- OUTPUT
-- movies_with_budget - 4014


-- Counting movies with available box-office revenue information.
SELECT COUNT(*) AS movies_with_revenue FROM movies WHERE revenue > 0;

-- OUTPUT
-- movies_with_revenue - 4026


-- Counting movies for which both budget and revenue are available.
SELECT COUNT(*) AS movies_with_both FROM movies WHERE budget > 0 AND revenue > 0;

-- OUTPUT
-- movies_with_both - 3434


-- Examining the zero, null, minimum, maximum and average movie ratings.
SELECT
    SUM(vote_average = 0) AS zero_rating,
    SUM(vote_average IS NULL) AS null_rating,
    MIN(vote_average) AS minimum_rating,
    MAX(vote_average) AS maximum_rating,
    AVG(vote_average) AS average_rating
FROM movies;

-- OUTPUT
-- zero_rating - 1126
-- null_rating - 0
-- minimum_rating - 0.000
-- maximum_rating - 10.000
-- average_rating - 5.4615987


-- Examining the zero, null, minimum, maximum and average number of votes received by movies.
SELECT
    SUM(vote_count = 0) AS zero_votes,
    SUM(vote_count IS NULL) AS null_votes,
    MIN(vote_count) AS minimum_votes,
    MAX(vote_count) AS maximum_votes,
    ROUND(AVG(vote_count), 0) AS average_votes
FROM movies;

-- OUTPUT
-- zero_votes - 1126
-- null_votes - 0
-- minimum_votes - 0
-- maximum_votes - 38844
-- average_votes - 1560


-- The numbers are exactly the same (1,126). It strongly suggests these movies simply have no votes/rating data, rather than having a genuine rating of 0.
UPDATE movies
SET vote_average = NULL, vote_count = NULL
WHERE vote_average = 0 AND vote_count = 0;
  

-- Checking null and zero values for ratings as well as votes counts.
SELECT
    SUM(vote_average IS NULL) AS null_rating,
    SUM(vote_count IS NULL) AS null_votes,
    SUM(vote_average = 0) AS zero_rating,
    SUM(vote_count = 0) AS zero_votes
FROM movies;

-- OUTPUT
-- null_rating - 1124
-- null_votes - 1124
-- zero_rating - 2
-- zero_votes - 2

-- So the original 1,126 zero-rating movies were not all identical after the update. 1,124 were converted to NULL, but 2 rows still have zero values.


-- Inspecting those two rows.
SELECT id, title, vote_average, vote_count FROM movies WHERE vote_average = 0 OR vote_count = 0;

-- OUTPUT
-- |      ID | Movie         | vote_average | vote_count |
-- | ------: | ------------- | -----------: | ---------: |
-- |  282991 | Narcissus     |            0 |          1 |
-- |  468241 | Joys          |            4 |          0 |
-- |  835579 | Yankeeski Kiz |            0 |          1 |
-- | 1245827 | Tanno Bar     |           10 |          0 |


-- To fix this, only setting their vote_average to NULL, while keeping vote_count = 0.
UPDATE movies SET vote_average = NULL WHERE vote_count = 0;
SELECT
    SUM(vote_average IS NULL) AS null_rating,
    SUM(vote_count IS NULL) AS null_votes,
    SUM(vote_average = 0) AS zero_rating,
    SUM(vote_count = 0) AS zero_votes
FROM movies;
   
   
-- Examining the zero, null, minimum, maximum and average movie popularity.
SELECT
    SUM(popularity = 0) AS zero_popularity,
    SUM(popularity IS NULL) AS null_popularity,
    MIN(popularity) AS minimum_popularity,
    MAX(popularity) AS maximum_popularity,
    AVG(popularity) AS average_popularity
FROM movies;

-- OUTPUT
-- zero_popularity - 0
-- null_popularity - 0
-- minimum_popularity - 1.17740
-- maximum_popularity - 365.03100
-- average_popularity - 6.650119621


-- Checking how many movies have missing or empty genre information.
SELECT
    SUM(genres IS NULL) AS null_genres,
    SUM(TRIM(genres) = '') AS empty_genres
FROM movies;

-- OUTPUT
-- null_genres - 0
-- empty_genres - 268


-- Replacing empty genres with NULL.
UPDATE movies SET genres = NULL WHERE TRIM(genres) = '';


-- Rehecking for empty genres.
SELECT
    SUM(genres IS NULL) AS null_genres,
    SUM(TRIM(genres) = '') AS empty_genres
FROM movies;

-- OUTPUT
-- null_genres - 268
-- empty_genres - 0


-- Replacing NULL genres with Unknown.
UPDATE movies SET genres = 'Unknown' WHERE genres IS NULL;


-- Verifying the Unknown genres.
SELECT COUNT(*) AS unknown_genres FROM movies WHERE genres = 'Unknown';

-- OUTPUT
-- unknown_genres - 268


-- Rechecking for Null genres.
SELECT SUM(genres IS NULL) AS null_genres FROM movies;

-- OUTPUT
-- null_genres - 0


-- Identifying the most common genre combinations in the dataset.
SELECT genres, COUNT(*) AS movie_count
FROM movies
WHERE genres IS NOT NULL AND TRIM(genres) <> ''
GROUP BY genres
ORDER BY movie_count DESC
LIMIT 20;


-- Identifying the distinct individual genres present in the dataset.
WITH RECURSIVE split_genres AS (
    SELECT
        id,
        TRIM(SUBSTRING_INDEX(genres, ',', 1)) AS genre,
        SUBSTRING(genres, LENGTH(SUBSTRING_INDEX(genres, ',', 1)) + 2) AS remaining
    FROM movies
    WHERE genres IS NOT NULL

    UNION ALL

    SELECT
        id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)) AS genre,
        CASE
            WHEN remaining LIKE '%,%'
                THEN SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
            ELSE ''
        END AS remaining
    FROM split_genres
    WHERE remaining <> ''
)
SELECT DISTINCT genre
FROM split_genres
WHERE genre <> ''
ORDER BY genre;

-- OUTPUT

-- | genre          |
-- |----------------|
-- | Action         |
-- | Adventure      |
-- | Animation      |
-- | Comedy         |
-- | Crime          |
-- | Documentary    |
-- | Drama          |
-- | Family         |
-- | Fantasy        |
-- | History        |
-- | Horror         |
-- | Music          |
-- | Mystery        |
-- | Romance        |
-- | Science Fiction|
-- | Thriller       |
-- | TV Movie       |
-- | Unknown        |
-- | War            |
-- | Western        |


-- Checking null and empty status.
SELECT
    SUM(status IS NULL) AS null_status,
    SUM(TRIM(status) = '') AS empty_status
FROM movies;

-- OUTPUT
-- null_status - 0
-- empty_status - 0


-- Analyzing the distribution of movie release statuses.
SELECT status, COUNT(*) AS movie_count
FROM movies
GROUP BY status
ORDER BY movie_count DESC;

-- OUTPUT

-- | Status          | Movies |
-- | --------------- | ------ |
-- | Released        |   9665 |
-- | Post Production |     56 |
-- | Planned         |     21 |
-- | In Production   |     17 |
-- | Canceled        |      7 |
-- | Rumored         |      4 |


-- Checking distinct, null and empty languages.
SELECT
    COUNT(DISTINCT original_language) AS languages,
    SUM(original_language IS NULL) AS null_language,
    SUM(TRIM(original_language) = '') AS empty_language
FROM movies;

-- OUTPUT
-- languages - 67
-- null_language - 0
-- empty_language - 0


-- Analyzing the number of movies by original language.
SELECT original_language, COUNT(*) AS movie_count
FROM movies
GROUP BY original_language
ORDER BY movie_count DESC;


-- Checking the distribution of the adult-content flag.
SELECT adult, COUNT(*) AS movie_count
FROM movies
GROUP BY adult;

-- OUTPUT
-- adult - 0
-- movie_count - 9770


-- Checking the distribution of the video flag.
SELECT video, COUNT(*) AS movie_count
FROM movies
GROUP BY video;

-- OUTPUT
-- video - 0
-- movie_count - 9770


-- Final data-quality summary.
SELECT
    COUNT(*) AS total_movies,
    SUM(id IS NULL) AS null_id,
    SUM(title IS NULL OR TRIM(title) = '') AS missing_title,
    SUM(original_title IS NULL OR TRIM(original_title) = '') AS missing_original_title,
    SUM(release_date IS NULL) AS null_release_date,
    SUM(runtime IS NULL) AS null_runtime,
    SUM(budget IS NULL) AS null_budget,
    SUM(revenue IS NULL) AS null_revenue,
    SUM(vote_average IS NULL) AS null_rating,
    SUM(vote_count IS NULL) AS null_votes,
    SUM(popularity IS NULL) AS null_popularity,
    SUM(status IS NULL OR TRIM(status) = '') AS missing_status,
    SUM(original_language IS NULL OR TRIM(original_language) = '') AS missing_language,
    SUM(genres IS NULL) AS null_genres
FROM movies;

-- OUTPUT

-- | Metric                   | Value |
-- | ------------------------ | ----: |
-- | `total_movies`           |  9770 |
-- | `null_id`                |     0 |
-- | `missing_title`          |     0 |
-- | `missing_original_title` |     0 |
-- | `null_release_date`      |    60 |
-- | `null_runtime`           |   439 |
-- | `null_budget`            |  5756 |
-- | `null_revenue`           |  5744 |
-- | `null_rating`            |  1126 |
-- | `null_votes`             |  1124 |
-- | `null_popularity`        |     0 |
-- | `missing_status`         |     0 |
-- | `missing_language`       |     0 |
-- | `null_genres`            |     0 |
