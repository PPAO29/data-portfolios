-- [1] select customers where country is in north america
SELECT *
FROM customers
WHERE UPPER(Country) IN ("USA","CANADA");
-- [2] count total genre from tracks
SELECT
g1.Name as "Genre Name",
count(t1.TrackId) as Quantity
FROM tracks t1
JOIN genres t2
ON t1.GenreId = t2.GenreId
GROUP BY "Genre Name"
ORDER BY Quantity DESC;
-- [3] select top 10 longest average song time by artists
SELECT
t3.Name as "Artist name",
ROUND((avg(t1.Milliseconds)/(1000*60.0)),2) as "Average song time (minutes)"
FROM tracks t1
JOIN albums t2
ON t1.AlbumId = t2.AlbumId
JOIN artists t3
ON t2.ArtistId = t3.ArtistId
GROUP BY t3.Name
ORDER BY "Average song time (minutes)" DESC
LIMIT 10;
-- [4] find sales in each quarter and year
SELECT
    STRFTIME("%Y", i1.InvoiceDate) AS Year,
    CASE
        WHEN STRFTIME("%m", i1.InvoiceDate) IN ('01', '02', '03') THEN 'Q1'
        WHEN STRFTIME("%m", i1.InvoiceDate) IN ('04', '05', '06') THEN 'Q2'
        WHEN STRFTIME("%m", i1.InvoiceDate) IN ('07', '08', '09') THEN 'Q3'
        WHEN STRFTIME("%m", i1.InvoiceDate) IN ('10', '11', '12') THEN 'Q4'
    END AS Quarter,
    ROUND(SUM(i2.UnitPrice * i2.Quantity),2) AS Sales
FROM invoices i1
JOIN invoice_items i2
    ON i1.InvoiceId = i2.InvoiceId
GROUP BY Year, Quarter
ORDER BY Year, Quarter;
-- [5] make self join on managers to employees
SELECT
e1.FirstName||' '||e1.LastName as "Full employees name",
COALESCE((e2.FirstName||' '||e2.LastName),"No Managers") as "Full managers name"
FROM employees e1
LEFT JOIN employees e2
ON e1.ReportsTo = e2.EmployeeId;
-- [6] select the most capacity of all songs of each artists in each genre
WITH ArtistCapacity AS (
    SELECT 
        t1.GenreId,
        t3.Name AS "Artist Name",
        SUM(t1.Bytes) AS total_capacity
    FROM tracks t1
    JOIN albums t2 ON t1.AlbumId = t2.AlbumId
    JOIN artists t3 ON t2.ArtistId = t3.ArtistId
    GROUP BY t1.GenreId, t3.ArtistId
)
SELECT 
    t4.Name AS "Genre Name",
    "Artist Name",
    round(total_capacity / 1073741824.0, 2) AS "Total Capacity (GB)"
FROM ArtistCapacity ac
JOIN genres t4 ON ac.GenreId = t4.GenreId
WHERE total_capacity = (
    SELECT MAX(total_capacity)
    FROM ArtistCapacity
    WHERE GenreId = ac.GenreId
)
ORDER BY "Total Capacity (GB)" DESC;
