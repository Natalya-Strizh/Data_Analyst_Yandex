---
SELECT COUNT(p.post_type_id) AS count_posts
FROM stackoverflow.posts p
JOIN stackoverflow.post_types pt ON p.post_type_id=pt.id
WHERE (p.score > 300 OR p.favorites_count >99) AND pt.type = 'Question'

---
WITH count_table AS (SELECT COUNT(p.id) AS count_1,
       EXTRACT(DAYS FROM CAST(creation_date AS date)) AS days
FROM stackoverflow.posts p
JOIN stackoverflow.post_types pt ON pt.id=p.post_type_id
WHERE (creation_date::date BETWEEN '01.11.2008' AND '18.11.2008')
                     AND pt.type = 'Question'
GROUP BY days)
SELECT ROUND(AVG(count_1))
FROM count_table

---
SELECT COUNT(DISTINCT u.id)
FROM stackoverflow.users u
JOIN stackoverflow.badges b ON u.id=b.user_id
WHERE u.creation_date::date = b.creation_date::date

---
SELECT COUNT(DISTINCT p.id)
FROM stackoverflow.posts p
JOIN stackoverflow.users u ON u.id=p.user_id
JOIN stackoverflow.votes v ON p.id = v.post_id
WHERE u.display_name = 'Joel Coehoorn' 

---
SELECT *,
       RANK() OVER (ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types
ORDER BY id

---
SELECT v.user_id,
       COUNT(v.id) AS count_votes
FROM stackoverflow.votes v
JOIN stackoverflow.vote_types vt ON v.vote_type_id=vt.id
WHERE vt.name = 'Close'
GROUP BY v.user_id
ORDER BY count_votes DESC, v.user_id DESC
LIMIT 10

---
WITH count_b AS (SELECT user_id, 
                 COUNT(id) AS count_badges
    FROM stackoverflow.badges
    WHERE DATE_TRUNC('day', creation_date) BETWEEN '2008-11-15' AND '2008-12-15'
    GROUP BY user_id)
SELECT user_id, 
       count_badges, 
       DENSE_RANK() OVER (ORDER BY count_badges DESC)
FROM count_b
ORDER BY count_badges DESC, user_id
LIMIT 10

---
WITH one AS (SELECT title,
       user_id,
       score,
       AVG(score) OVER (PARTITION BY user_id) AS avg_score
FROM stackoverflow.posts
WHERE title IS NOT NULL AND score != 0)
SELECT title,
       user_id,
       score,
       ROUND(avg_score)
FROM one

---
WITH one AS (SELECT b.user_id AS user_id,
       COUNT(b.id) AS count_id
FROM stackoverflow.users u 
JOIN stackoverflow.badges b ON u.id=b.user_id
GROUP BY user_id
HAVING COUNT(b.id) > 1000)
SELECT p.title
FROM stackoverflow.posts p
JOIN one o ON o.user_id=p.user_id
WHERE p.title IS NOT NULL

---
SELECT id,
       views, 
       CASE
           WHEN views >= 350 THEN 1
           WHEN views < 350 AND views > 99 THEN 2
           WHEN views < 100 THEN 3
       END
FROM stackoverflow.users
WHERE location LIKE '%United States%' AND views != 0

---
WITH grouppy AS (SELECT id,
       views, 
       CASE
           WHEN views >= 350 THEN 1
           WHEN views < 350 AND views > 99 THEN 2
           WHEN views < 100 THEN 3
       END AS case_group
FROM stackoverflow.users
WHERE location LIKE '%United States%' AND views != 0),
gpouppy_2 AS (SELECT id,
       case_group,
       views,
       MAX(views) OVER (PARTITION BY case_group) AS max_views
FROM grouppy)
SELECT id,
       case_group,
       views
FROM gpouppy_2
WHERE views = max_views
ORDER BY views DESC, id

---
SELECT EXTRACT(DAYS FROM CAST(creation_date AS date)) AS days,
       COUNT(id) AS count_users,
       SUM(COUNT(id)) OVER (ORDER BY EXTRACT(DAYS FROM creation_date::date)) AS prirost
FROM stackoverflow.users
WHERE DATE_TRUNC('day', CAST(creation_date AS date)) BETWEEN '01.11.2008' AND '30.11.2008'
GROUP BY days

---
WITH one AS (SELECT u.id AS id,
       u.creation_date AS date,
       FIRST_VALUE(p.creation_date) OVER (PARTITION BY p.user_id ORDER BY p.creation_date) AS first
FROM stackoverflow.users u
JOIN stackoverflow.posts p ON u.id=p.user_id)
SELECT DISTINCT id, 
       first - date
FROM one

---
SELECT DATE_TRUNC('month', creation_date::date)::date AS date,
       SUM(views_count) AS sum_views
FROM stackoverflow.posts
WHERE EXTRACT(YEAR FROM creation_date::date) = 2008
GROUP BY date
ORDER BY sum_views DESC

---
SELECT u.display_name,
       COUNT(DISTINCT u.id)
FROM stackoverflow.users u
JOIN stackoverflow.posts p ON u.id=p.user_id
JOIN stackoverflow.post_types pt ON pt.id=p.post_type_id
WHERE pt.type = 'Answer' AND p.creation_date::date <= u.creation_date::date + INTERVAL '1 month'
GROUP BY u.display_name
HAVING COUNT(pt.type) > 100
ORDER BY u.display_name

---
SELECT COUNT(id) AS count_posts,
       DATE_TRUNC('month', creation_date::date)::date AS month
FROM stackoverflow.posts
WHERE user_id IN (
SELECT p.user_id
FROM stackoverflow.posts p
JOIN stackoverflow.users u ON u.id=p.user_id
WHERE DATE_TRUNC('month', u.creation_date::date)::date = '01.09.2008' AND
      DATE_TRUNC('month', p.creation_date::date)::date = '01.12.2008')
GROUP BY month
ORDER BY month DESC

---
SELECT user_id,
       creation_date,
       views_count,
       SUM(views_count) OVER (PARTITION BY user_id ORDER BY creation_date)
FROM stackoverflow.posts

---
WITH one AS (SELECT DISTINCT user_id,
       COUNT(DISTINCT EXTRACT(DAY FROM creation_date::date)) AS count_day
FROM stackoverflow.posts
WHERE creation_date::date BETWEEN '01.12.2008' AND '07.12.2008'
GROUP BY 1)
SELECT ROUND(AVG(count_day))
FROM one

---
WITH one AS (SELECT EXTRACT(MONTH FROM creation_date::date) AS month,
       COUNT(id) AS count_id,
       LAG(COUNT(id)) OVER () AS previos
FROM stackoverflow.posts
WHERE creation_date::date BETWEEN '01.09.2008' AND '31.12.2008'
GROUP BY month)
SELECT month,
       count_id,
       ROUND(((count_id::numeric/previos)*100 - 100),2)
FROM one 

---
WITH one AS (SELECT user_id,
       COUNT(id) AS count
FROM stackoverflow.posts
GROUP BY user_id
ORDER BY count DESC
LIMIT 1),
two AS (SELECT id,
       creation_date,
       EXTRACT(WEEK FROM creation_date::date) AS week
FROM stackoverflow.posts p
JOIN one o ON p.user_id=o.user_id)

SELECT DISTINCT week,
       LAST_VALUE(creation_date) OVER (PARTITION BY week ORDER BY creation_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM two
WHERE creation_date::date BETWEEN '01.10.2008' AND '31.10.2008';
