---
SELECT COUNT(id)
FROM company
WHERE status = 'closed'

---
SELECT funding_total
FROM company
WHERE country_code = 'USA'
  AND category_code = 'news'
GROUP BY id
ORDER BY funding_total DESC

---
SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash'
  AND EXTRACT(YEAR FROM CAST(acquired_at AS date)) BETWEEN 2011 AND 2013

---
SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%'

---
SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
  AND last_name LIKE 'K%'

---
SELECT country_code,
       SUM(funding_total) AS sum
FROM company
GROUP BY country_code
ORDER BY sum DESC

---
SELECT funded_at,
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) != 0
  AND MIN(raised_amount) != MAX(raised_amount)

---
SELECT CASE
           WHEN invested_companies >= 100 THEN 'high_activity'
           WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
           WHEN invested_companies < 20 THEN 'low_activity'
       END,
       *
FROM fund

---
SELECT ROUND(AVG(investment_rounds)) AS avg,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
FROM fund
GROUP BY activity
ORDER BY avg

---
SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies) AS avg
FROM fund 
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) BETWEEN 2010 AND 2012
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY avg DESC, country_code
LIMIT 10

---
SELECT p.first_name,
       p.last_name,
       ed.instituition
FROM people AS p
LEFT OUTER JOIN education AS ed ON p.id=ed.person_id

---
SELECT c.name,
       COUNT(DISTINCT ed.instituition) AS count
FROM people AS p
INNER JOIN education AS ed ON ed.person_id=p.id
INNER JOIN company AS c ON c.id=p.company_id
GROUP BY c.name
ORDER BY count DESC
LIMIT 5;

---
SELECT DISTINCT c.name
FROM company AS c
INNER JOIN funding_round AS f ON c.id=f.company_id
WHERE c.status = 'closed'
  AND f.is_first_round=1 AND f.is_last_round=1

---
WITH
table_1 AS (SELECT DISTINCT c.name, c.id
            FROM company AS c
            INNER JOIN funding_round AS f ON c.id=f.company_id
            WHERE c.status = 'closed'
            AND f.is_first_round=1 AND f.is_last_round=1)
          
SELECT DISTINCT p.id
FROM people AS p
INNER JOIN table_1 ON p.company_id=table_1 .id

---
WITH
table_1 AS (SELECT DISTINCT c.name, c.id
            FROM company AS c
            INNER JOIN funding_round AS f ON c.id=f.company_id
            WHERE c.status = 'closed'
            AND f.is_first_round=1 AND f.is_last_round=1)
          
SELECT DISTINCT p.id AS id_person,
       ed.instituition AS id_education
FROM people AS p
INNER JOIN table_1 ON p.company_id=table_1 .id
INNER JOIN education AS ed ON p.id=ed.person_id

---
WITH
table_1 AS (SELECT DISTINCT c.name, c.id
            FROM company AS c
            INNER JOIN funding_round AS f ON c.id=f.company_id
            WHERE c.status = 'closed'
            AND f.is_first_round=1 AND f.is_last_round=1)
          
SELECT DISTINCT p.id AS id_person,
       COUNT(ed.instituition) AS count_id_education
FROM people AS p
INNER JOIN table_1 ON p.company_id=table_1 .id
INNER JOIN education AS ed ON p.id=ed.person_id
GROUP BY id_person

---
WITH
table_1 AS (SELECT DISTINCT c.name, c.id
            FROM company AS c
            INNER JOIN funding_round AS f ON c.id=f.company_id
            WHERE c.status = 'closed'
            AND f.is_first_round=1 AND f.is_last_round=1),
table_2 AS (SELECT DISTINCT p.id AS id_person,
                   COUNT(ed.instituition) AS count_id_education
            FROM people AS p
            INNER JOIN table_1 ON p.company_id=table_1 .id
            INNER JOIN education AS ed ON p.id=ed.person_id
            GROUP BY id_person)
   
SELECT AVG(table_2.count_id_education)
FROM table_2

---
WITH
table_1 AS (SELECT DISTINCT c.name, c.id
            FROM company AS c
            INNER JOIN funding_round AS f ON c.id=f.company_id
            WHERE c.name = 'Facebook'),
table_2 AS (SELECT p.id AS id_person,
                   COUNT(ed.instituition) AS count_id_education
            FROM people AS p
            INNER JOIN table_1 ON p.company_id=table_1 .id
            INNER JOIN education AS ed ON p.id=ed.person_id
            GROUP BY id_person)
   
SELECT AVG(table_2.count_id_education)
FROM table_2

---
SELECT f.name,
       c.name,
       fr.raised_amount
FROM investment AS i
INNER JOIN company AS c ON c.id=i.company_id
INNER JOIN fund AS f ON f.id=i.fund_id
INNER JOIN funding_round AS fr ON fr.id=i.funding_round_id
WHERE c.milestones > 6
  AND EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) BETWEEN 2012 AND 2013

---
SELECT c1.name, --  компания-покупатель
       a.price_amount,
       c2.name, -- компания, которую купили
       c2.funding_total,
       ROUND(a.price_amount/c2.funding_total)
FROM acquisition AS a
LEFT OUTER JOIN company AS c1 ON a.acquiring_company_id=c1.id --  компания-покупатель
LEFT OUTER JOIN company AS c2 ON a.acquired_company_id=c2.id -- компания,кот куп-ли
WHERE a.price_amount != 0
   AND c2.funding_total != 0 
ORDER BY a.price_amount DESC, a.acquired_company_id DESC
LIMIT 10

---
SELECT c.name,
       EXTRACT(MONTH FROM CAST(fr.funded_at AS date))
FROM company AS c 
LEFT OUTER JOIN funding_round AS fr ON fr.company_id=c.id
WHERE category_code = 'social'
  AND EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) BETWEEN 2010 AND 2013
  AND fr.raised_amount != 0

---
WITH
table_1 AS  (SELECT f.name,
         EXTRACT(MONTH FROM CAST(fr.funded_at AS date)) AS month
         FROM funding_round AS fr
         LEFT OUTER JOIN investment AS i ON i.funding_round_id=fr.id
         LEFT OUTER JOIN fund AS f ON f.id=i.fund_id
         WHERE EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) BETWEEN 2010 AND 2013
           AND f.country_code = 'USA'),
table_2 AS  (SELECT EXTRACT(MONTH FROM CAST(acquired_at AS date)) AS month,
                COUNT(acquired_company_id) AS acquired_company,
                SUM(price_amount) AS price
         FROM acquisition
         WHERE EXTRACT(YEAR FROM CAST(acquired_at AS date)) BETWEEN 2010 AND 2013
         GROUP BY month)
SELECT table_1.month,
       COUNT(DISTINCT table_1.name) AS count_name,
       table_2.acquired_company AS count_company,
       table_2.price
FROM table_1
INNER JOIN table_2 ON table_1.month=table_2.month
GROUP BY table_1.month, table_2.acquired_company, table_2.price

---
WITH
table_11 AS (SELECT country_code,
                    AVG(funding_total) AS avg
             FROM company
             WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = 2011
             GROUP BY country_code),
table_12 AS (SELECT country_code,
                    AVG(funding_total) AS avg
             FROM company
             WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = 2012
             GROUP BY country_code),
table_13 AS (SELECT country_code,
                    AVG(funding_total) AS avg
             FROM company
             WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = 2013
             GROUP BY country_code)
           
SELECT table_11.country_code,
       table_11.avg AS avg_11,
       table_12.avg AS avg_12,
       table_13.avg AS avg_13
FROM table_11
INNER JOIN table_12 ON table_11.country_code = table_12.country_code
INNER JOIN table_13 ON table_12.country_code = table_13.country_code
ORDER BY avg_11 DESC;
