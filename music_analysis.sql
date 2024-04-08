
-- Q1 : Who is the senior most employee based on the job title ?

SELECT * 
FROM employee
ORDER BY levels DESC 
LIMIT 1;

-- Q2 : Which countries have most invoices?

SELECT billing_country, COUNT(1) as count
FROM invoice
GROUP BY billing_country
ORDER BY count desc
LIMIT 1;

-- Q3 What are top 3 invoice values?

SELECT total FROM invoice
ORDER BY total desc LIMIT 3;

-- Q4 Which city has the best customers? Write a query that returns one city that has the highest sum of invoice totals.
-- 	Return both the city name and sum of all invoice totals.
    
SELECT billing_city as city , SUM(total) as sum
FROM invoice 
GROUP BY billing_city
ORDER BY sum  DESC
LIMIT 1;

-- Q5 Who is the best customer ? The customer who has spend the most money will be declared as the best customer.
-- 	Write a query that returns the person who has spent the most money.
--     
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) as money_spend
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id,c.first_name, c.last_name
ORDER BY money_spend DESC 
LIMIT 1;

-- Q6 Write a query to return the email, first name and last name and Genre of all Rock Music listeners.
-- Return your list alphabetically by email starting with A.

SELECT DISTINCT customer.customer_id,customer.first_name,customer.last_name,customer.email
FROM track 
JOIN genre ON track.genre_id = genre.genre_id
jOIN invoice_line ON track.track_id = invoice_line.track_id
jOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
JOIN customer ON invoice.customer_id = customer.customer_id
WHERE genre.name = 'Rock'
ORDER BY customer.email;

-- Q7 Lets invite the artists that have written most rock music in our dataset.
-- 	Write a query that returns the artist name and total track of the top 10 rock bands
    
SELECT artist.artist_id, artist.name, COUNT(*) as total_track
FROM track
JOIN album2  ON track.album_id = album2.album_id
JOIN artist ON album2.artist_id = artist.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.name,artist.artist_id
ORDER BY total_track DESC
LIMIT 10;

-- Q8 Return all the tracks that have a song length longer than the average song length.
--  Return the Name and Milliseconds for each track.Order by song length with longest songs listed first.
 
 SELECT name, milliseconds
 FROM track
 WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
 ORDER BY milliseconds DESC;
 
--  Q9 Find how much amount spent by each customer on  best selling artist. 
-- 	Write a query to return  the artist name , customer name and total spent.

with best_selling_artist AS (
select artist.artist_id as artist_id ,artist.name as artist_name, SUM(invoice_line.unit_price * invoice_line.quantity ) as total_sales
from track
join album2 on track.album_id = album2.album_id
join artist on artist.artist_id = album2.artist_id
join invoice_line on track.track_id = invoice_line.track_id
GROUP BY artist.artist_id,artist.name
ORDER BY total_sales DESC
LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- Q10 We want to find out the most popular music genre in each country.
-- 	We determine the most popular genre as genre with highest amount of purchases.
--     Write a query that returns each country with top genre. Countries for which maximum 
--     amount of purchases is shared return all genres.
    
WITH popular_genre AS 
(
    SELECT  customer.country as country, genre.name as genre, genre.genre_id, COUNT(invoice_line.quantity) AS purchases,
	RANK() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 1,2,3
	ORDER BY 1 ASC, 4 DESC
)
SELECT p.country,p.genre,p.purchases FROM popular_genre p WHERE RowNo = 1

    
    
    
