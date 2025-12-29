
CREATE TABLE Books(
Book_ID	SERIAL	PRIMARY KEY,
Title	VARCHAR(100),	
Author	VARCHAR(100),
Genre	VARCHAR(50),	
Published_Year	INT,
Price	NUMERIC(10,2),
Stock	INT
);
SELECT * FROM Books;

DROP TABLE IF EXISTS customers;
CREATE TABLE customers(
Customer_ID	SERIAL PRIMARY KEY,
Name VARCHAR(100),
Email VARCHAR(100),
Phone VARCHAR(15),
City VARCHAR(50),
Country VARCHAR(100)
);
ALTER TABLE customers
ALTER COLUMN country TYPE VARCHAR(150);

SELECT * FROM customers;


DROP TABLE IF EXISTS orders;
CREATE TABLE orders(
Order_ID SERIAL PRIMARY KEY,
Customer_ID	INT REFERENCES customers(Customer_ID),
Book_ID	INT REFERENCES books(Book_ID),
Order_Date DATE,
Quantity INT,
Total_Amount NUMERIC(10,2)
);

SELECT * FROM orders;
--IMPORT DATA IN books:
COPY Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock)
FROM 'C:/csv files/Books.csv'
CSV HEADER;


-- Import into customers
COPY customers(Customer_ID, Name, Email, Phone, City, Country)
FROM 'C:/csv files/Customers.csv'
CSV HEADER;


--IMPORT IN orders
COPY orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount)
FROM 'C:/csv files/Orders.csv'
CSV HEADER;

-- 11 basic queries:

-- 1.retrieve all the books from the "fiction" genre
SELECT * FROM Books
WHERE genre = 'Fiction';


-- 2.find books published after the year 1950.
SELECT * FROM Books
WHERE published_year > 1950;


-- 3.list all the customers from canada.
SELECT * FROM customers
WHERE country = 'Canada';

-- 4.show orders placed in nov 2023.
SELECT * FROM orders
WHERE order_date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5.retrieve the total stock of books available.
SELECT SUM(stock) AS total_quantity_books
FROM Books;

-- 6.find the detail of the most expensive book.
SELECT * FROM Books
ORDER BY price DESC
LIMIT 1;

-- 7.show customers who ordered more than 1 quantity of books.
SELECT c.customer_id,c.name,c.email,c.phone,c.city,c.country,
       o.order_id,o.customer_id,o.book_id,o.order_date,o.quantity,o.total_amount
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
WHERE O.quantity > 1;


-- 8.retrieve all the orders where the total amount exceeds $20.
SELECT * FROM orders
WHERE total_amount > 20;


-- 9.list all the "genre" available in the books table.
SELECT DISTINCT genre
FROM Books;

-- 10.find the book with the lowest stock.
SELECT * FROM Books
ORDER BY stock ASC
LIMIT 5;


-- 11.calculate the total revenue generated from all the orders.
SELECT SUM(total_amount) AS total_revenue
FROM orders;


-- 9 Advanced queries

-- 1.retrieve the total number of books sold for each genre.
SELECT b.genre,
SUM(o.quantity) AS total_quantity
FROM Books b JOIN orders o
ON b.book_id = o.book_id
GROUP BY b.genre;


-- 2.find the avg price of the book in "fantasy" genre.
SELECT ROUND(AVG(price), 2) AS avg_price  --2 is done so that we get 2 digits after the decimal
FROM Books
WHERE genre = 'Fantasy';


-- 3.list customers who have placed atleast 2 orders.(imp note: we use having instead of where if the case is about the aggregate function)
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) >= 2;

-- 4. find the most frequently ordered book.
SELECT b.title,
COUNT(o.order_id) AS total_order
FROM Books b JOIN orders o 
ON b.book_id = o.book_id
GROUP BY b.title
ORDER BY total_order DESC
LIMIT 7;

-- 5.show the top 3 most expensive book from "fantasy" genre.
SELECT book_id,title,genre,price
FROM Books 
WHERE genre = 'Fantasy'
ORDER BY price DESC
LIMIT 3;


-- 6.show the total quantity of books sold by each author.
SELECT b.author,
SUM(quantity) AS total_books_sold
FROM Books b JOIN orders o
ON b.book_id = o.book_id
GROUP BY b.author;

-- 7.list the cities where customer who spend over $30 are located.
SELECT c.city,
SUM(o.total_amount) AS money_spent
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.city
HAVING SUM(o.total_amount) > 30;

-- 8.find the customer who spend the most in order.
SELECT c.customer_id,c.name,
SUM(total_amount) AS highest_order
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id,c.name
ORDER BY highest_order DESC
LIMIT 1;

-- 9.calculate the stock remaining after fulfilling all orders.
SELECT b.book_id, b.title, b.stock,
COALESCE(SUM(o.quantity), 0) AS order_quantity,
b.stock - COALESCE(SUM(o.quantity), 0) AS remaning_stock
FROM books b
LEFT JOIN orders o 
ON b.book_id = o.book_id
GROUP BY b.book_id, b.title, b.stock;


