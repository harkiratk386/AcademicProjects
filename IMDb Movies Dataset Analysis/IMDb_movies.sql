/*
IMDb movies dataset analysis
Skills used: Joins, CTE's, Aggregate Functions, Functions, Temp Tables
*/

#Query 1
#Find top 10 Production Companies 
SELECT company as Production_company, SUM(budget_ic) AS Total_budget_$, SUM(gross_ic) AS Total_earnings_$, ((SUM(gross_ic)-SUM(budget_ic))/(SUM(gross_ic))*100) AS Net_Profit_Margin, COUNT(name) AS Number_Movies_Produced
FROM movies_clean 
GROUP BY company
ORDER BY SUM(gross_ic) DESC
LIMIT 10;

#--------------------------------------------------------------------------------------------------------------------------
#Query 2
#Find top 10 Production Companies based on highest agrregate votes 
SELECT company as Production_company , SUM(votes) as Total_votes
FROM movies_clean 
GROUP BY company
ORDER BY SUM(votes) DESC
LIMIT 10;

#--------------------------------------------------------------------------------------------------------------------------
#Query 3
#Most profitable star cast for production companies
DROP FUNCTION highest_gross_ic_star_by_company;

DELIMITER $$
CREATE FUNCTION highest_gross_ic_star_by_company (p_company VARCHAR(255))
RETURNS  VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE result VARCHAR(255);
  SELECT  star  INTO result 
  FROM movies_clean 
  WHERE company = p_company
  GROUP BY star
  ORDER BY SUM(gross_ic) DESC
  LIMIT 1;
  RETURN result ;
END $$
DELIMITER ;

SELECT companies.company as Production_company, highest_gross_ic_star_by_company(companies.company) AS Star
FROM (
  SELECT 'Warner Bros.' AS company
  UNION
  SELECT 'Twentieth Century Fox' AS company
  UNION
  SELECT 'Universal Pictures' AS company
  UNION
  SELECT 'Walt Disney Productions' AS company
  UNION
  SELECT 'Columbia Pictures' AS company
  UNION
  SELECT 'Paramount Pictures' AS company
  UNION
  SELECT 'Twentieth Century Fox' AS company
  UNION
  SELECT 'Marvel Studios' AS company
) AS companies;

#--------------------------------------------------------------------------------------------------------------------------
#Query 4
#Score Distribution (Top Companies)

drop function Percentage_movies_with_IMDbscore_morethan_7;
DELIMITER $$
CREATE FUNCTION Percentage_movies_with_IMDbscore_morethan_7 (p_company VARCHAR(255))
RETURNS  VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE result VARCHAR(255);
  SELECT 100.0 * SUM(CASE WHEN score > 7 THEN 1 ELSE 0 END) / COUNT(*)   INTO result 
  FROM movies_clean 
  WHERE company = p_company
  GROUP BY company;
  RETURN result ;
END $$
DELIMITER ;

SELECT companies.company as Production_company, Percentage_movies_with_IMDbscore_morethan_7(companies.company) AS Percentage_of_Movies_IMDb_Score_more_than_7
FROM (
  SELECT 'Warner Bros.' AS company
  UNION
  SELECT 'Twentieth Century Fox' AS company
  UNION
  SELECT 'Universal Pictures' AS company
  UNION
  SELECT 'Walt Disney Productions' AS company
  UNION
  SELECT 'Columbia Pictures' AS company
  UNION
  SELECT 'Paramount Pictures' AS company
  UNION
  SELECT 'Twentieth Century Fox' AS company
  UNION
  SELECT 'Marvel Studios' AS company
) AS companies;

#--------------------------------------------------------------------------------------------------------------------------
#Query 5
#US Movies with budget_ic less than 3 millions
select name, year, genre, rating, runtime, budget_ic, gross_ic, (gross_ic - budget_ic) as profit
from movies_clean 
where country = "United States" and budget_ic < 3000000;

#--------------------------------------------------------------------------------------------------------------------------
#Query 6
#For US movies with less than 3 million budget_ic, calculate average profit for each genre (order by profit)
select genre, count(genre) as movie_count, avg(gross_ic - budget_ic) as average_profit
from movies_clean 
where country = "United States" and budget_ic < 3000000
group by genre
order by average_profit desc
limit 10;

#--------------------------------------------------------------------------------------------------------------------------
#Query 7

#For US movies with more than 3 million budget_ic, calculate average profit for each genre (order by profit)
select genre, count(genre) as movie_count, avg(gross_ic - budget_ic) as average_profit
from movies_clean 
where country = "United States" and budget_ic >= 3000000
group by genre
order by average_profit desc
limit 10;

#--------------------------------------------------------------------------------------------------------------------------
#Query 8
#The top 50 most profitable budget_ic < 3m US movies
select name, rating, genre, runtime, round(((gross_ic - budget_ic) / 1000000), 2) as profit_million, round((budget_ic / 1000000), 2) as budget_ic_million
from movies_clean 
where country = "United States" and budget_ic < 3000000
order by profit_million desc
limit 50;

#--------------------------------------------------------------------------------------------------------------------------
#Query 9
#Marvel Movies

SELECT name, gross_ic
FROM movies_clean 
WHERE company LIKE '%MARVEL%'
ORDER BY gross DESC; 

#--------------------------------------------------------------------------------------------------------------------------
#Query 10
#Profitable Genres
SELECT DISTINCT GENRE, avg (gross_ic-budget_ic) as profit
FROM movies_clean
ORDER BY profit DESC;

#Popular genres during each year
select distinct genre, year, count(name)
from movies_clean
where genre = 'drama'
group by year
order by year desc;
	

