/* Kaggle_data table creation */

CREATE TABLE kaggle_data (
    id INT NOT NULL AUTO_INCREMENT,
    book_id INT NOT NULL,
    title VARCHAR(500) NOT NULL,
    authors VARCHAR(1000) NOT NULL,
    average_rating DECIMAL(5 , 2 ) NOT NULL,
    isbn VARCHAR(50) NOT NULL,
    isbn13 BIGINT NOT NULL,
    language_code VARCHAR(10) NOT NULL,
    num_pages SMALLINT NOT NULL,
    ratings_count BIGINT NOT NULL,
    comments_count BIGINT NOT NULL,
    publication_date VARCHAR(50) NOT NULL,
    publisher VARCHAR(256) NOT NULL,
    PRIMARY KEY (id)
);

/* Load kaggle data into kaggle_data table */

LOAD DATA INFILE  
'H:/kaggle data/goodreadsbooks/Book1.csv'
INTO TABLE kaggle_data  
CHARACTER SET utf8mb4
FIELDS ENCLOSED BY '"'
TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(book_id, title, authors, average_rating, isbn, isbn13, language_code, num_pages, ratings_count, comments_count, publication_date, publisher);

-- Split up author name for normalization
CREATE TEMPORARY TABLE book_split AS (
SELECT 
  book_id,
  title,
  SUBSTRING_INDEX(SUBSTRING_INDEX(authors, '/', n.digit+1), '/', -1) author,
  average_rating,
  isbn,
  isbn13,
  language_code,
  num_pages,
  ratings_count,
  comments_count,
  publication_date,
  publisher
FROM
  kaggle_data
  INNER JOIN
  (SELECT 0 digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
   SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
   SELECT 8  UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
   SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL
   SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL
   SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL
   SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL
   SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31 UNION ALL
   SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35 UNION ALL
   SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL
   SELECT 40 UNION ALL SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43 UNION ALL
   SELECT 44 UNION ALL SELECT 45 UNION ALL SELECT 46 UNION ALL SELECT 47 UNION ALL
   SELECT 48 UNION ALL SELECT 49  
   ) n
  ON LENGTH(REPLACE(authors, '/' , '')) <= LENGTH(authors)-n.digit
);

-- SELECT * FROM book_split
-- where author like 'Emmanuel%'

-- Duplicate author name
DELETE FROM book_split 
WHERE
    author = 'Emmanuel Le Roy-Ladurie';

/* Begin table creation for normalization */

-- publish table
CREATE TABLE publish (
    publisher_id INT NOT NULL AUTO_INCREMENT,
    publisher VARCHAR(256) NOT NULL,
    CONSTRAINT pk_publisher PRIMARY KEY (publisher_id)
);

-- book table
CREATE TABLE book (
    book_id INT NOT NULL AUTO_INCREMENT,
    isbn13 BIGINT NOT NULL,
    isbn VARCHAR(50) NOT NULL,
    lang_code VARCHAR(5) NOT NULL,
    num_page SMALLINT NOT NULL,
    avg_rating DECIMAL(3 , 2 ) NOT NULL,
    rating_count BIGINT NOT NULL,
    comments_count BIGINT NOT NULL,
    publication_date VARCHAR(256) NOT NULL,
    publisher_id INT NOT NULL,
    CONSTRAINT pk_book_id PRIMARY KEY (book_id),
	CONSTRAINT fk_publisher_id FOREIGN KEY (publisher_id)
        REFERENCES publish (publisher_id)
);

-- author table
CREATE TABLE author (
    author_id INT NOT NULL AUTO_INCREMENT,
    author_name VARCHAR(256) NOT NULL,
    CONSTRAINT pk_author PRIMARY KEY (author_id)
);

-- book_title table
CREATE TABLE book_title (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    title VARCHAR(256) NOT NULL,
    CONSTRAINT fk_book_id1 FOREIGN KEY (book_id)
        REFERENCES book (book_id),
    CONSTRAINT fk_author_id1 FOREIGN KEY (author_id)
        REFERENCES author (author_id)
);

/* End table creation */

/* Begin data population */

/* publish data */
INSERT INTO publish (publisher)
SELECT publisher FROM kaggle_data
GROUP BY publisher;

/* book data */
INSERT INTO book (book_id, isbn13, isbn, lang_code, avg_rating, rating_count, comments_count, num_page, publication_date, publisher_id)
SELECT id, isbn13, isbn, language_code, average_rating, ratings_count, comments_count, num_pages, publication_date, publisher_id
FROM kaggle_data
inner join publish
using (publisher);

/* author table */
INSERT INTO author (author_name)
SELECT
    DISTINCT(CONCAT( SUBSTRING_INDEX(SUBSTRING_INDEX(author, ' ', 1), ' ', -1),' ',TRIM( SUBSTR(author, LOCATE(' ', author)) ) ) ) AS author_name
FROM book_split;

/* temporary table to store author_id column */
CREATE TEMPORARY TABLE book_author (
SELECT a.author_id, b.isbn13 FROM book_split b
INNER JOIN author a
ON b.author = a.author_name
);

/* book_title data */
INSERT INTO book_title(book_id, author_id, title)
SELECT id, author_id, title FROM book_author
INNER JOIN kaggle_data bk
USING (isbn13);

/* End data population */

DROP TEMPORARY TABLE IF EXISTS book_split ;
DROP TEMPORARY TABLE IF EXISTS book_author;

-- Change the format of publication_date column
UPDATE book 
SET 
    publication_date = STR_TO_DATE(publication_date, '%m/%d/%Y');

-- There are two input errors in the data where the date does not exist on the calendar
UPDATE book 
SET 
    publication_date = '2000-10-31'
WHERE
    book_id = 8181;

UPDATE book 
SET 
    publication_date = '1982-06-01'
WHERE
    book_id = 11099;

-- Change the datatype of publication_date column from varchar to date type
ALTER TABLE book MODIFY publication_date DATE NOT NULL;

-- Query

SELECT 
    lang_code, COUNT(lang_code)
FROM
    book
GROUP BY lang_code;

-- Top 10 most rated books
SELECT 
    title, b.rating_count
FROM
    book b
        INNER JOIN
    book_title USING (book_id)
GROUP BY book_id , title , rating_count
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
SELECT 
    title, avg_rating
FROM
    book AS b
        INNER JOIN
    book_title AS bt ON b.book_id = bt.book_id
GROUP BY title , rating_count
HAVING rating_count > 1000
ORDER BY avg_rating DESC
LIMIT 10;

-- Rating distribution for books
SELECT 
    SUM(CASE
        WHEN avg_rating >= 0 AND avg_rating < 1 THEN 1
        ELSE 0
    END) 'Books with Ratings Between 0 and 1',
    SUM(CASE
        WHEN avg_rating >= 1 AND avg_rating < 2 THEN 1
        ELSE 0
    END) 'Books with Ratings Between 1 and 2',
    SUM(CASE
        WHEN avg_rating >= 2 AND avg_rating < 3 THEN 1
        ELSE 0
    END) 'Books with Ratings Between 2 and 3',
    SUM(CASE
        WHEN avg_rating >= 3 AND avg_rating < 4 THEN 1
        ELSE 0
    END) 'Books with Ratings Between 3 and 4',
    SUM(CASE
        WHEN avg_rating >= 4 THEN 1
        ELSE 0
    END) 'Books with Ratings Greater than 4',
    COUNT(book_id) 'Total Number of Books'
FROM
    book;

-- Top 10 Author of most books
SELECT 
    author_name, COUNT(title)
FROM
    author
        INNER JOIN
    book_title USING (author_id)
        INNER JOIN
    book USING (book_id)
GROUP BY author_name
ORDER BY COUNT(title) DESC
LIMIT 10;

-- Average rating for all books
SELECT 
    ROUND(AVG(avg_rating), 2) AS 'Average rating'
FROM
    book;
    
-- Top 10 books with most pages
SELECT 
    title, author_name, num_page
FROM
    book
        INNER JOIN
    book_title USING (book_id)
        INNER JOIN
    author USING (author_id)
GROUP BY title , author_name
ORDER BY num_page DESC
LIMIT 10;

-- Top 10 highly rated authors
SELECT 
    author_name,
    COUNT(title) AS 'Number of Books with High Rating'
FROM
    book
        INNER JOIN
    book_title USING (book_id)
        INNER JOIN
    author USING (author_id)
WHERE
    avg_rating >= 4.3
GROUP BY author_name
ORDER BY COUNT(title) DESC
LIMIT 10;

-- top 10 books published year
SELECT 
    YEAR(publication_date) AS 'year',
    COUNT(*) AS 'number of books published'
FROM
    book
GROUP BY YEAR(publication_date)
ORDER BY COUNT(*) DESC
LIMIT 10;