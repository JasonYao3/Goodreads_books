-- Data Manipulation Language (DML)

/* Begin data population */

/* book data */
INSERT INTO book (book_id, isbn13, isbn, lang_code, avg_rating, rating_count, comments_count, num_page, publication_date, publisher_id)
SELECT id, isbn13, isbn, language_code, average_rating, ratings_count, comments_count, num_pages, publication_date, publisher_id
FROM kaggle_data 
inner join publish 
using (publisher);

update book
set publication_date = str_to_date(publication_date, '%m/%d/%Y');

-- There are few input errors in the data where the date does not exist on the calendar

-- There is no day 31th in 2000 novemeber
-- Found out the book id and mannully update the date, from Amazon the book was published on Oct.31, 2000
update book
set publication_date = '2000-10-31'
where book_id = 8181;

-- Error Code: 1292. Incorrect date value: '1982-06-31' for column 'publication_date' at row 11099

-- June 1st 1982 is the correct publication date
update book
set publication_date = '1982-06-01'
where book_id = 11099;

ALTER TABLE book modify publication_date Date not null;

/* publish data */
INSERT INTO publish (publisher, book_id)
SELECT b.book_id, k.publisher FROM book b
INNER JOIN kaggle_data k 
USING (isbn13)
GROUP BY publisher;


/* author data */
-- some author names have multiple spaces between them
-- split the names, trim them, then concat them back into full name
-- from 9234 names down to 9203 (due to bad style)
INSERT INTO author (author_name)
SELECT
    distinct(concat( SUBSTRING_INDEX(SUBSTRING_INDEX(author, ' ', 1), ' ', -1),' ',TRIM( SUBSTR(author, LOCATE(' ', author)) ) ) )as author_name
FROM book_split;

/* book_title data */
CREATE TEMPORARY TABLE book_author (
SELECT a.author_id, b.isbn13 FROM book_split b
INNER JOIN author a
ON b.author = a.author_name
);

INSERT INTO book_title(book_id, author_id, title)
SELECT id, author_id, title FROM book_author
INNER JOIN kaggle_data bk
USING (isbn13);

/* End data population */
