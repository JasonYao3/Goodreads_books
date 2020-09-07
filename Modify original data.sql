# This query creates a table to store the original Goodreads book dataset from Kaggle by the author Soumik. 
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
)  DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_UNICODE_CI;

# This query loads Kaggle dataset into the kaggle_data table created from the query above.
LOAD DATA INFILE  
'H:/kaggle data/goodreadsbooks/Book_data.csv'
INTO TABLE kaggle_data  
CHARACTER SET utf8mb4
FIELDS ENCLOSED BY '"'
TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(book_id, title, authors, average_rating, isbn, isbn13, language_code, num_pages, ratings_count, comments_count, publication_date, publisher);

-- Split multiple author names for normalization
CREATE TABLE book_split AS (SELECT book_id,
    title,
    SUBSTRING_INDEX(SUBSTRING_INDEX(authors, '/', n.digit + 1),
            '/',
            - 1) author,
    average_rating,
    isbn,
    isbn13,
    language_code,
    num_pages,
    ratings_count,
    comments_count,
    publication_date,
    publisher FROM
    kaggle_data
        INNER JOIN
    (SELECT 0 digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35 UNION ALL SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL SELECT 40 UNION ALL SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43 UNION ALL SELECT 44 UNION ALL SELECT 45 UNION ALL SELECT 46 UNION ALL SELECT 47 UNION ALL SELECT 48 UNION ALL SELECT 49) n ON LENGTH(REPLACE(authors, '/', '')) <= LENGTH(authors) - n.digit);

-- SELECT * FROM book_split
-- where author like 'Emmanuel%'

DELETE FROM book_split 
WHERE
    author = 'Emmanuel Le Roy-Ladurie';


-- this script shows the max authors for a book
-- https://stackoverflow.com/questions/12344795/count-the-number-of-occurrences-of-a-string-in-a-varchar-field
SELECT 
    MAX(count)
FROM
    (SELECT 
        title,
            authors,
            ROUND((CHAR_LENGTH(authors) - CHAR_LENGTH(REPLACE(authors, '/', ''))) / CHAR_LENGTH('/')) AS count
    FROM
        kaggle_data) a