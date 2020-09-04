-- Number of books in all the different languages
SELECT lang_code, COUNT(lang_code) 
FROM book
GROUP BY lang_code;

-- Top 10 most rated books
SELECT title, b.rating_count FROM book b
-- use case when 
INNER JOIN book_title bt
USING (book_id)
GROUP BY book_id, title, rating_count
ORDER BY rating_count DESC
LIMIT 10;

-- Top 10 books with most text reviews
SELECT title, comments_count, ROW_NUMBER() OVER (ORDER BY comments_count DESC) ranking
FROM book
INNER JOIN book_title
USING (book_id)
GROUP BY title, comments_count
LIMIT 10;

-- Top 10 books with highest average rating with at least 1000 ratings
SELECT title, avg_rating FROM book b
INNER JOIN book_title
USING (book_id)
GROUP BY title, rating_count
HAVING rating_count > 1000 
ORDER BY avg_rating DESC
LIMIT 10;

-- Top 10 Author of most books
SELECT author_name, COUNT(title) FROM author
INNER JOIN book_title
USING (author_id)
INNER JOIN book
USING (book_id)
GROUP BY author_name
ORDER BY COUNT(title) DESC
LIMIT 10;

-- Average rating for all books
select round(avg(avg_rating),2) AS 'Average rating' from book

-- Top 10 books with most pages
SELECT title, author_name, num_page FROM book
INNER JOIN book_title
USING (book_id)
INNER JOIN author
USING (author_id)
GROUP BY title, author_name
ORDER BY num_page DESC
LIMIT 10;

-- Top 10 highly rated authors
SELECT author_name, COUNT(title) AS 'Number of Books with High Rating' FROM book
INNER JOIN book_title
USING (book_id)
INNER JOIN author
USING (author_id)
WHERE avg_rating >= 4.3
GROUP BY author_name
ORDER BY COUNT(title) DESC
LIMIT 10;

-- rating distribution for books
SELECT
SUM(CASE WHEN avg_rating >= 0 AND avg_rating < 1 THEN 1 ELSE 0 END) 'Ratings Between 0 and 1' ,
-- count(case when avg_rating >= 0 and avg_rating < 1 then 1 else null end) 'Ratings Between 0 and 1',
SUM(CASE WHEN avg_rating >= 1 AND avg_rating < 2 THEN 1 ELSE 0 END)'Ratings Between 1 and 2',
SUM(CASE WHEN avg_rating >= 2 AND avg_rating < 3 THEN 1 ELSE 0 END) 'Ratings Between 2 and 3',
SUM(CASE WHEN avg_rating >= 3 AND avg_rating < 4 THEN 1 ELSE 0 END) 'Ratings Between 3 and 4',
SUM(CASE WHEN avg_rating >= 4 THEN 1 ELSE 0 END) 'Ratings Greater than 4',
COUNT(book_id) 'Total'
FROM book;

SELECT
ROUND((SUM(CASE WHEN avg_rating >= 0 AND avg_rating < 1 THEN 1 ELSE 0 END)/ COUNT(book_id)) * 100,2) 'Percentage Ratings Between 0 and 1',
ROUND((SUM(CASE WHEN avg_rating >= 1 AND avg_rating < 2 THEN 1 ELSE 0 END)/ COUNT(book_id)) * 100,2) 'Percentage Ratings Between 1 and 2',
ROUND((SUM(CASE WHEN avg_rating >= 2 AND avg_rating < 3 THEN 1 ELSE 0 END) / COUNT(book_id)) * 100,2) 'Percentage Ratings Between 2 and 3',
ROUND((SUM(CASE WHEN avg_rating >= 3 AND avg_rating < 4 THEN 1 ELSE 0 END) / COUNT(book_id)) * 100,2) 'Percentage Ratings Between 3 and 4',
ROUND((SUM(CASE WHEN avg_rating >= 4 THEN 1 ELSE 0 END) / COUNT(book_id)) * 100,2) 'Percentage Ratings Greater than 4'
FROM book;

SELECT publisher, COUNT(title) as 'books published' FROM book
INNER JOIN book_title
USING (book_id)
INNER JOIN publish
USING (publisher_id)
GROUP BY publisher
ORDER BY COUNT(title) DESC
LIMIT 10;

-- top 10 books published year
select  year(publication_date) as 'year', count(*) as 'number of books published' 
 from book
group by year(publication_date)
order by count(*) desc
limit 10;
 
 se
 -- oldest publication date and most recent publication date
 select min(publication_date) , max(publication_date) from publish_date
 
 select * from publish_date
 group by 
 