-- CREATE TABLE netflix_films (
--     show_id VARCHAR(50) PRIMARY KEY,
--     type VARCHAR(20),
--     title VARCHAR(255),
--     director VARCHAR(255),
--     cast VARCHAR(255),
--     country VARCHAR(255),
--     date_added DATE,
--     release_year INT,
--     rating VARCHAR(10),
--     duration VARCHAR(20),
--     listed_in VARCHAR(255),
--     description TEXT
-- );


-- ALTER TABLE netflix_films MODIFY COLUMN cast TEXT;

CREATE TABLE imdb_top_1000 (
    Poster_Link VARCHAR(255),
    Series_Title VARCHAR(255),
	Released_Year VARCHAR(20),
    Certificate VARCHAR(20),
    Runtime VARCHAR(20),
    Genre VARCHAR(255),
    IMDB_Rating DECIMAL(3, 1),
    Overview TEXT,
    Meta_score INT,
    Director VARCHAR(255),
    Star1 VARCHAR(255),
    Star2 VARCHAR(255),
    Star3 VARCHAR(255),
    Star4 VARCHAR(255),
    No_of_Votes INT,
    Gross VARCHAR(20)
);

-- ALTER TABLE imdb_top_1000 MODIFY COLUMN Released_Year VARCHAR(20);

select *
from imdb_top_1000
where  Released_Year = 1995

update imdb_top_1000
set Released_Year = 1995
where Series_Title = "Apollo 13"

select count(*)
from netflix_films nf
inner join imdb_top_1000 id
on nf.title = id.Series_Title

