-- Data Definition Language (DDL)

/* Begin table creation */
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
	CONSTRAINT fk_publisher_id FOREIGN KEY (publisher_id) REFERENCES publish(publisher_id)
);

CREATE TABLE publish (
	publisher_id INT NOT NULL AUTO_INCREMENT,
    publisher VARCHAR(256) NOT NULL,
    CONSTRAINT pk_publisher PRIMARY KEY (publisher_id)
);

CREATE TABLE author (
	author_id INT NOT NULL AUTO_INCREMENT,
    author_name VARCHAR(256) NOT NULL,
    CONSTRAINT pk_author PRIMARY KEY (author_id)
);
	    
CREATE TABLE book_title (
	book_id INT NOT NULL,
	author_id INT NOT NULL,
    title VARCHAR(256) NOT NULL,
	CONSTRAINT fk_book_id1 FOREIGN KEY (book_id) REFERENCES book(book_id),
    CONSTRAINT fk_author_id1 FOREIGN KEY (author_id) REFERENCES author(author_id)
);

/* End table creation */

