LOAD DATA INFILE  
'H:/kaggle data/goodreadsbooks/Book1.csv'
INTO TABLE kaggle_data  
CHARACTER SET utf8mb4
FIELDS ENCLOSED BY '"'
TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(book_id, title, authors, average_rating, isbn, isbn13, language_code, num_pages, ratings_count, comments_count, publication_date, publisher);
