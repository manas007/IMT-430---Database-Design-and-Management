-- 1.What is the shortest movie?
select TOP 1 movieTitle from tblMovie where movieRuntime is not null ORDER BY movieRuntime asc

-- 2. What is the movie with the most number of votes?
select TOP 1 movieTitle from tblMovie order by movieVoteCount desc

--3.Which movie made the most net profit?
select TOP 1 a.movieTitle from (
select movieTitle,  (movieRevenue - movieBudget) as profit from tblMovie ) a order by a.profit desc

--4. Which movie lost the most money?
select TOP 1 a.movieTitle from (
select movieTitle,  (movieRevenue - movieBudget) as profit from tblMovie ) a order by a.profit asc

--5.How many movies were made in the 80’s?
select count(*) from tblMovie where movieReleaseDate between '1980-01-01' and '1989-12-31'

--6. What is the most popular movie released in the year 1980?
select TOP 1 m.movieTitle from tblMovie m where m.movieReleaseDate between '1980-01-01' and '1980-12-31'  order by moviePopularity desc

--7. How long was the longest movie made before 1900?
select max(movieRuntime) from tblMovie m  where m.movieReleaseDate < '1900-01-01'

-- 8. Which language has the shortest movie?
select TOP 1 l.languageName from tblMovie m
inner join tblLanguage l 
on m.languageID = l.languageID
where m.movieRuntime = (select min(movieRuntime) from tblMovie)

-- 9. Which collection has the highest total popularity?
select a.collectionName from (
select TOP 1 c.collectionID, c.collectionName, sum(t.moviePopularity) as summ from tblMovie t 
inner join tblCollection c 
on t.collectionID = c.collectionID
group by c.collectionID, c.collectionName
order by summ desc) a

-- 10. Which language has the most movies in production or post-production?
select languageName from tblLanguage where languageID = 
(select TOP 1 a.languageID from (
select t.languageID, count(*) as movieCount from tblMovie t 
inner join tblStatus s
on t.statusID = s.statusID
where s.statusName in('In Production', 'Post Production')
group by t.languageID
) a )

-- 11. What was the most expensive movie that ended up getting canceled?
select movieTitle from tblMovie where movieBudget = 
(select max(movieBudget) from tblMovie t inner join tblStatus s on t.statusID = s.statusID
where s.statusName = 'Canceled')
and statusID = (
select statusID from tblStatus where statusName = 'Canceled')

-- 12. How many collections have movies that are in production for the language French (FR)
select count(t.collectionID) from tblMovie t
inner join tblStatus s
on t.statusID = s.statusID
inner join tblLanguage l 
on t.languageID = l.languageID
where l.languageCode = 'FR'
and s.statusName = 'In Production'

-- 13. List the top ten rated movies that have received more than 5000 votes
select TOP 10 movieTitle from tblMovie where movieVoteCount > 5000 order by movieVoteAverage desc

-- 14. Which collection has the most movies associated with it?
select TOP 1 c.collectionName, count(m.movieTitle) as cnt from tblMovie m inner join tblCollection c on m.collectionID = c.collectionID group by c.collectionName order by cnt desc

-- 15. What is the collection with the longest total duration?
select TOP 1 c.collectionName , sum(m.movieRuntime) as sm from tblMovie m inner join tblCollection c on m.collectionID = c.collectionID group by c.collectionName order by sm desc

-- 16. Which collection has made the most net profit?
select TOP 1 c.collectionName , sum(m.movieRevenue - m.movieBudget) as sm from tblMovie m inner join tblCollection c on m.collectionID = c.collectionID group by c.collectionName order by sm desc

-- 17. List the top 100 movies by their duration from longest to shortest
select top 100 m.movieTitle, m.movieRuntime from tblMovie m order by m.movieRuntime DESC;

-- 18. Which languages have more than 25,000 movies associated with them?
select l.languageName, count(m.movieID) as cnt from tblMovie m inner join tblLanguage l on m.languageID = l.languageID group by l.languageName having  count(m.movieID) > 25000 order by cnt desc

-- 19. Which collections had all their movies made in the 80’s?
select a.collectionName from (
select c.collectionName, min(m.movieReleaseDate) as firstMovieDate, max(m.movieReleaseDate) as lastMovieDate from tblMovie m inner join tblCollection c 
on m.collectionID = c.collectionID
group by c.collectionName) a
where a.firstMovieDate >= '1980-01-01' and a.lastMovieDate <= '1989-12-31'

-- 20. In the language that has the most number of movies in the database, how many movies start with “The”? (You may not hard-code a language)
select count(m.movieID) from tblMovie m where m.languageID = (select TOP 1 m.languageID from tblMovie m inner join tblLanguage l on m.languageID = l.languageID
group by m.languageID order by count(m.languageID) desc) and LOWER(SUBSTRING(m.movieTitle,1,3)) = 'the'
