CREATE TABLE PUBLISHER (
	Publisher_Name VARCHAR(30) NOT NULL,
	Phone VARCHAR(15),
	Address VARCHAR(50),
	PRIMARY KEY (Publisher_Name)
);

CREATE TABLE LIBRARY_BRANCH (
    Branch_Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Branch_Name VARCHAR(20) NOT NULL,
    Branch_Address VARCHAR(50)
);

CREATE TABLE BORROWER (
    Card_No INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Name VARCHAR(20) NOT NULL,
    Address VARCHAR(50),
    Phone VARCHAR(15)
);

CREATE TABLE BOOK (
    Book_Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Title VARCHAR(40) NOT NULL,
    Publisher_Name VARCHAR(30),
    FOREIGN KEY (Publisher_Name) REFERENCES PUBLISHER(Publisher_Name) ON DELETE CASCADE
);

CREATE TABLE BOOK_LOANS (
	Book_Id INT NOT NULL, 
	Branch_Id INT NOT NULL,
	Card_No INT NOT NULL,
	Date_Out DATE,
	Due_Date DATE,
	Returned_Date DATE,
	PRIMARY KEY (Book_Id, Branch_Id, Card_No),
	FOREIGN KEY (Book_Id) REFERENCES BOOK(Book_Id) ON DELETE CASCADE,
	FOREIGN KEY (Branch_Id) REFERENCES LIBRARY_BRANCH(Branch_Id) ON DELETE CASCADE,
FOREIGN KEY (Card_No) REFERENCES BORROWER(Card_No) ON DELETE CASCADE
);

CREATE TABLE BOOK_COPIES (
	Book_Id INT NOT NULL,
	Branch_Id INT NOT NULL,
	No_Of_Copies INT,
	PRIMARY KEY (Book_Id, Branch_Id),
	FOREIGN KEY (Book_Id) REFERENCES BOOK(Book_Id) ON DELETE CASCADE,
	FOREIGN KEY (Branch_Id) REFERENCES LIBRARY_BRANCH(Branch_Id) ON DELETE CASCADE
);

CREATE TABLE BOOK_AUTHORS (
	Book_Id INT NOT NULL,
Author_Name VARCHAR(30),
PRIMARY KEY(Book_Id, Author_Name),
FOREIGN KEY (Book_Id) REFERENCES BOOK(Book_Id) ON DELETE CASCADE
);


-- .read project2.sql
-- .mode csv
-- .import --skip 1 Publisher.csv PUBLISHER
-- .import --skip 1 Library_Branch.csv LIBRARY_BRANCH
-- .import --skip 1 Borrower.csv BORROWER
-- .import --skip 1 Book.csv BOOK
-- .import --skip 1 Book_Loans.csv BOOK_LOANS
-- .import --skip 1 Book_Copies.csv BOOK_COPIES
-- .import --skip 1 Book_Authors.csv BOOK_AUTHORS
-- .mode column
-- .header on
-- .mode box

-- SELECT 'PUBLISHER' AS TABLE_NAME, COUNT(*) AS COUNT FROM PUBLISHER;
-- SELECT 'LIBRARY_BRANCH' AS TABLE_NAME, COUNT(*) AS COUNT FROM LIBRARY_BRANCH;
-- SELECT 'BORROWER' AS TABLE_NAME, COUNT(*) AS COUNT FROM BORROWER;
-- SELECT 'BOOK' AS TABLE_NAME, COUNT(*) AS COUNT FROM BOOK;
-- SELECT 'BOOK_LOANS' AS TABLE_NAME, COUNT(*) AS COUNT FROM BOOK_LOANS;
-- SELECT 'BOOK_COPIES' AS TABLE_NAME, COUNT(*) AS COUNT FROM BOOK_COPIES;
-- SELECT 'BOOK_AUTHORS' AS TABLE_NAME, COUNT(*) AS COUNT FROM BOOK_AUTHORS;


-- -- Question 1: Insert yourself as a New Borrower. Do not provide the Card_no in your query
-- INSERT INTO BORROWER (Name, Address, Phone) 
-- VALUES ('Emmet Smith', '1232 Street Ave, Texas, TX 32984', '123-456-7890');

-- -- Question 3: Increase the number of book_copies by 1 for the ‘East Branch’
-- UPDATE BOOK_COPIES
-- SET No_Of_Copies = No_Of_Copies + 1
-- WHERE Branch_Id = 3;


-- -- Question 5: Return all Books that were loaned between March 5, 2022 until March 23, 2022. List Book
-- -- title and Branch name, and how many days it was borrowed for.
-- SELECT 
--     BOOK.Title AS Book_Title,
--     LIBRARY_BRANCH.Branch_Name AS Branch_Name,
--     JULIANDAY(
--         COALESCE(BOOK_LOANS.Returned_Date, DATE('now'))
--     ) - JULIANDAY(BOOK_LOANS.Date_Out) AS Days_Borrowed
-- FROM BOOK_LOANS
-- JOIN BOOK ON BOOK_LOANS.Book_Id = BOOK.Book_Id
-- JOIN LIBRARY_BRANCH ON BOOK_LOANS.Branch_Id = LIBRARY_BRANCH.Branch_Id
-- WHERE BOOK_LOANS.Date_Out BETWEEN '2022-03-05' AND '2022-03-23';

-- -- Question 7: Create a report that will return all branches with the number of books borrowed per branch
-- -- separated by if they have been returned, still borrowed, or late.

-- SELECT
--     LIBRARY_BRANCH.branch_name AS Branch,
--     -- Count of books returned
--     (SELECT COUNT(*)
--      FROM BOOK_LOANS
--      WHERE BOOK_LOANS.Branch_Id = LIBRARY_BRANCH.Branch_Id
-- 		AND BOOK_LOANS.Returned_Date IS NOT NULL
-- 		AND BOOK_LOANS.Returned_Date != 'NULL') AS Returned,
--     -- Count of books still borrowed
--     (SELECT COUNT(*)
--      FROM BOOK_LOANS
--      WHERE BOOK_LOANS.Branch_Id = LIBRARY_BRANCH.Branch_Id
--      	AND BOOK_LOANS.Returned_Date = 'NULL') AS Still_Borrowed,
--     -- Count of books returned late
--     (SELECT COUNT(*)
--      FROM BOOK_LOANS
--      WHERE BOOK_LOANS.Branch_Id = LIBRARY_BRANCH.Branch_Id
-- 		AND BOOK_LOANS.Returned_Date IS NOT NULL
-- 		AND BOOK_LOANS.Returned_Date != 'NULL'
-- 		AND BOOK_LOANS.Returned_Date > BOOK_LOANS.Due_Date) AS Late
-- FROM LIBRARY_BRANCH;



-- -- Question 8: List all the books (title) and the maximum number of days that they were borrowed.
-- SELECT BOOK.title, 
--     MAX((JULIANDAY(BOOK_LOANS.returned_date) - JULIANDAY(BOOK_LOANS.date_out))) AS Max_Days_Borrowed
-- FROM BOOK
-- JOIN BOOK_LOANS ON BOOK.book_id = BOOK_LOANS.book_id
-- WHERE BOOK_LOANS.returned_date IS NOT NULL
-- GROUP BY BOOK.title;


-- -- Question 9: Create a report for Ethan Martinez with all the books they borrowed. List the book title and author. 
-- -- Also, calculate the number of days each book was borrowed for and if any book is late being returned. Order the results by the date_out.
-- SELECT 
--     BOOK.title AS Title,
--     BOOK_AUTHORS.author_name AS Author,
--     ((JULIANDAY(BOOK_LOANS.returned_date) - JULIANDAY(BOOK_LOANS.date_out))) AS Days_Borrowed,
--     (BOOK_LOANS.returned_date > BOOK_LOANS.due_date) AS Late
-- FROM BOOK
-- JOIN BOOK_AUTHORS ON BOOK.book_id = BOOK_AUTHORS.book_id
-- JOIN BOOK_LOANS ON BOOK.book_id = BOOK_LOANS.book_id
-- JOIN BORROWER ON BOOK_LOANS.card_no = BORROWER.card_no
-- WHERE BORROWER.name = 'Ethan Martinez'
-- ORDER BY BOOK_LOANS.date_out;


-- QUERY 1
-- ALTER TABLE BOOK_LOANS
-- ADD COLUMN Late INTEGER DEFAULT 0;

-- UPDATE BOOK_LOANS
-- SET Late = 1
-- WHERE Returned_Date > Due_Date;



-- QUERY 2
-- ALTER TABLE LIBRARY_BRANCH
-- ADD COLUMN LateFee REAL;

-- UPDATE LIBRARY_BRANCH
-- SET LateFee = 0.50
-- WHERE branch_name = 'Main Branch';

-- UPDATE LIBRARY_BRANCH
-- SET LateFee = 0.75
-- WHERE branch_name = 'West Branch';

-- UPDATE LIBRARY_BRANCH
-- SET LateFee = 1.00
-- WHERE branch_name = 'East Branch';


-- QUERY 3 
-- CREATE VIEW vBookLoanInfo AS
-- SELECT
--     BL.card_no AS Card_No,
--     B.name AS Borrower_Name,
--     BL.date_out AS Date_Out,
--     BL.due_date AS Due_Date,
--     BL.returned_date AS Returned_Date,
--     -- Calculate total days loaned
--     CASE
--         WHEN BL.returned_date IS NOT NULL THEN 
--             CAST((JULIANDAY(BL.returned_date) - JULIANDAY(BL.date_out)) AS INTEGER)
--         ELSE
--             CAST((JULIANDAY('now') - JULIANDAY(BL.date_out)) AS INTEGER)
--     END AS TotalDays,
--     BK.title AS Book_Title,
--     -- Calculate days returned late
--     CASE
--         WHEN BL.returned_date IS NOT NULL AND BL.returned_date > BL.due_date THEN
--             CAST((JULIANDAY(BL.returned_date) - JULIANDAY(BL.due_date)) AS INTEGER)
--         ELSE
--             0
--     END AS Days_Returned_Late,
--     BL.branch_id AS Branch_ID,
--     -- Calculate late fee balance
--     CASE
--         WHEN BL.returned_date IS NOT NULL AND BL.returned_date > BL.due_date THEN
--             CAST((JULIANDAY(BL.returned_date) - JULIANDAY(BL.due_date)) AS INTEGER) *
--             LB.LateFee
--         ELSE
--             0
--     END AS LateFeeBalance
-- FROM
--     BOOK_LOANS BL
-- JOIN
--     BORROWER B ON BL.card_no = B.card_no
-- JOIN
--     BOOK BK ON BL.book_id = BK.book_id
-- JOIN
--     LIBRARY_BRANCH LB ON BL.branch_id = LB.branch_id;
