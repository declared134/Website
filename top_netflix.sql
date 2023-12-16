
-- Netflix Movies that are on IMDB's Top 1000 List

ALTER TABLE netflix_films RENAME COLUMN director TO director1

select *
from netflix_films nf
inner join imdb_top_1000 id
on nf.title = id.Series_Title

CREATE VIEW FilmsJoin AS
select *
from netflix_films nf
inner join imdb_top_1000 id
on nf.title = id.Series_Title

with cte as (

select *
from netflix_films nf
inner join imdb_top_1000 id
on nf.title = id.Series_Title

)

select sum(gross)
from cte

SELECT rating, COUNT(*) as rating_count, avg(IMDB_Rating)
FROM FilmsJoin
GROUP BY rating
order by rating_count desc

select gross
from FilmsJoin

-- add anew column to turn comma gorss num to int
-- ALTER TABLE imdb_top_1000
-- ADD COLUMN gross_num INT;

-- cast to into and replace to signed int
update imdb_top_1000
set gross_num = CAST(REPLACE(gross, ',', '') AS SIGNED)

select  genre, sum(gross_num) as TotalGross
from imdb_top_1000
group by genre

-- include gross_num
-- alter view filmsjoin as
-- select *
-- from netflix_films nf
-- inner join imdb_top_1000 id
-- on nf.title = id.Series_Title

select star1, count(star1) as MovieStarFreq
from filmsjoin
group by star1
order by MovieStarFreq desc


select genre, sum(No_of_Votes) as TotalVotes
from filmsjoin
group by genre 
order by TotalVotes desc

select director, count(director) as MovieStarFreq
from filmsjoin
group by director
order by MovieStarFreq desc

select title, gross
from filmsjoin
order by gross desc

select certificate, avg(imdb_rating), sum(gross_num) as Gross
from filmsjoin
group by certificate
order by Gross desc

-- seeing how each movie comapres to the genre
SELECT title, imdb_rating, gross_num, genre,
AVG(gross_num) OVER (PARTITION BY genre) 
AS GenreAverage FROM filmsjoin

-- seeing how each movie compares to the director's average
SELECT
  title,
  director,
  gross_num,
  genre,
  DirFreq,
  DirectorAverage
FROM (
  SELECT
    title,
    director,
    gross_num,
    genre,
    COUNT(*) OVER (PARTITION BY director) AS DirFreq,
    AVG(gross_num) OVER (PARTITION BY director) AS DirectorAverage
    FROM
    filmsjoin
) AS director_stats
having DirFreq > 1 
order by DirFreq desc

select title, gross_num, country, CountryFreq, CountryGross
from (
select title, country, count(*) over (partition by country) as CountryFreq,
avg(gross_num) over (partition by country) as CountryGross, gross_num
from filmsjoin
) as stats
having CountryFreq > 1
order by CountryFreq desc

-- big stars affect on ratings and sales

with StarsStats as (

	select title, star1, count(*) over (partition by star1) as TitlesNum,
    imdb_rating, gross_num, avg(gross_num) over (partition by star1) as StarAvgGross,
    count(*) over (partition by star2) as TitlesNum2
    from filmsjoin
    group by title, star1, imdb_rating, gross_num, star2
)
select title, star1, gross_num, StarAvgGross, (TitlesNum + TitlesNum2) as TotalTopBilling
from starsstats
where TitlesNum > 1

-- stored procedure

DELIMITER $$
create procedure  show_films()
begin
select * from filmsjoin;
end $$
DELIMITER ;

DELIMITER $$
create procedure find_movie(in id int)
begin
select * 
from filmsjoin
where show_id = id;
end $$
DELIMITER ;

call find_movie(16944044);

call show_films();

-- show all movies from a certain year

DELIMITER $$
create procedure movies_of_the_year(year varchar(55))
begin
select *
from filmsjoin
where release_year = year;
end $$
DELIMITER ;

call movies_of_the_year(2001)

-- find the number of years it took for each movie to be added

DELIMITER $$
create procedure num_of_years_to_add(movie_title varchar(255))
begin
select title, release_year, date_added, year(date_added)-(release_year) as
"Number of Years to be Added"
from filmsjoin
where title = movie_title;
end $$
DELIMITER ;

call num_of_years_to_add("The Departed");

-- stored proceudre query all movies from a director by name
delimiter $$
create procedure get_dir_movies(director varchar(255))
begin 
select *
from filmsjoin
where director1 = director;
end $$
delimiter ; 


call get_dir_movies("Martin Scorsese");

-- temporary table

create temporary table 
top_rated_movies(title varchar(255),
IMDB_Rating decimal(3,2), release_year varchar(20)
, gross_num int,
director varchar(255));

insert into top_rated_movies(
title, IMDB_Rating, release_year,
gross_num)
select title, IMDB_Rating, release_year,
gross_num
from filmsjoin
where IMDB_Rating > 8.0;

select *
from top_rated_movies
order by IMDB_Rating desc

alter table imdb_top_1000
add column double_gross decimal(12,2)
after gross_num;

update imdb_top_1000
set double_gross = gross_num*2;


create trigger before_gross_update
before update on imdb_top_1000
for each row 
set new.double_gross =( new.gross_num *2)

-- under 5million double gross again, double gross will be 4x the original gross
update imdb_top_1000
set gross_num = gross_num * 2
where gross_num < 5000000

select *
from imdb_top_1000
where gross_num < 5000000

