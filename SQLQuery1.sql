
-- take a look at dataset
SELECT TOP 10 * 
FROM [Video Games].dbo.VideoGames

-- only pull necessary columns
CREATE VIEW cleaned_data AS
SELECT DISTINCT title, console, total_sales, release_date
FROM [Video Games].dbo.VideoGames

-- get best sellers, separated by console
SELECT * from cleaned_data
ORDER BY total_sales DESC       

-- see which games are on multiple consoles
SELECT title, console, total_sales
from [Video Games].dbo.VideoGames
WHERE total_sales IS NOT NULL
GROUP BY title, console, total_sales


-- which console has the most games
SELECT console, COUNT(title) AS num_titles
FROM cleaned_data
GROUP BY console   
ORDER BY num_titles DESC  

-- which console has made the most money
SELECT
    console,
    SUM(total_sales) AS sales_by_console 
FROM
    cleaned_data
	WHERE total_sales IS NOT NULL
	GROUP BY console--, total_sales 
	ORDER BY 2 DESC

-- which game has made the most money
SELECT
    title,
    SUM(total_sales) AS sales_by_title
FROM
    cleaned_data
	WHERE total_sales IS NOT NULL
	AND NOT total_sales = 0 
	GROUP BY title
	ORDER BY 2 DESC

	    
-- let's see which series has the most games 

-- first find all the series
CREATE VIEW series AS 
SELECT *
FROM cleaned_data
WHERE console = 'series'     


-- first get distinct titles from video games
-- then join that on distinct series

-- games in a series
SELECT DISTINCT(cleaned_data.title) AS game_title, 
series.title  AS series_title
FROM cleaned_data 
JOIN series 
ON cleaned_data.title LIKE CONCAT(series.title, '%')
GROUP BY series.title, cleaned_data.title
--HAVING COUNT(series.title) > 1

-- view with number of games in a series
CREATE VIEW Z AS
SELECT DISTINCT cleaned_data.title AS game_title, 
cleaned_data.total_sales, 
series.title  AS series_title, 
SUM(COUNT(DISTINCT(series.title))) OVER(PARTITION BY series.title ORDER BY series.title)    
AS num_games_in_series -- 
FROM cleaned_data 
JOIN series
ON cleaned_data.title LIKE CONCAT(series.title, '%') 
GROUP BY series.title, cleaned_data.title, cleaned_data.total_sales


-- find game series with at least 2 games
SELECT * FROM Z
WHERE num_games_in_series > 1
ORDER BY num_games_in_series DESC 

-- see which series has made most money
SELECT series_title,  
SUM(total_sales) AS sales_by_series
FROM Z 
WHERE num_games_in_series > 1
GROUP BY series_title, num_games_in_series
ORDER BY 2 DESC   

 -- gives you the correct number of games in a series
SELECT DISTINCT(game_title), series_title,
SUM(COUNT(DISTINCT(series_title))) OVER(PARTITION BY series_title ORDER BY series_title)    
AS num_games_in_series
FROM Z    
JOIN series
ON Z.game_title LIKE CONCAT(series.title, '%') 
WHERE num_games_in_series > 1
GROUP BY series_title, Z.game_title--, cleaned_data.total_sales
ORDER BY num_games_in_series DESC

-- ok lets find out xbox vs playstation sales over time
--SELECT TOP 10 * FROM cleaned_data

-- find all distinct consoles
SELECT DISTINCT(console),
SUM(total_sales)
FROM cleaned_data 
WHERE total_sales IS NOT NULL
GROUP BY console 
ORDER BY SUM(total_sales) DESC

-- sony consoles are PS2, PS3, PS, PS4, PSP, PSV
-- microsoft X360, XOne, XB
-- ninentdo Wii, DS, GBA, GC, 3ds, n64, NES, NS, WiiU, GB
-- PC
-- other 2600 SNES, SAT, GEN, DC, GBC, PSN, NG, WS, SCD, VC, WW, XBL, 3DO, PCE, GG, Mob, OSX, PCFX

-- create view to group consoles with parent companies
CREATE VIEW companies AS
SELECT console,
total_sales, 
CASE  WHEN console IN ('PS2', 'PS3', 'PS', 'PS4', 'PSP', 'PSV') THEN 'Sony'
		 WHEN console IN ('X360', 'XOne', 'XB') THEN 'Microsoft'
		 WHEN console IN ('Wii', 'DS', 'GBA', 'GC', '3DS', 'N64', 'NES', 'NS', 'WiiU', 'GB') THEN 'Nintendo'
		 ELSE 'Other'
		 END AS company
FROM cleaned_data
GROUP BY total_sales, console,  
CASE  WHEN console IN ('PS2', 'PS3', 'PS', 'PS4', 'PSP', 'PSV') THEN 'Sony'
		 WHEN console IN ('X360', 'XOne', 'XB') THEN 'Microsoft'
		 WHEN console IN ('Wii', 'DS', 'GBA', 'GC', '3DS', 'N64', 'NES', 'NS', 'WiiU', 'GB') THEN 'Nintendo'
		 ELSE 'Other'
		 END 
HAVING total_sales IS NOT NULL

   
-- total company sales 
SELECT DISTINCT(company),
SUM(total_sales) OVER(PARTITION BY company ORDER BY company)  AS company_sales
FROM companies
GROUP by company, total_sales  
