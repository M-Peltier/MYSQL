-- Group By
-- When you use the GROUP BY clause in a MySQL query, it groups together rows that have the same values in the specified column or columns.
-- GROUP BY is going to allow us to group rows that have the same data and run aggregate functions on them

SELECT *
FROM parks_and_recreation.employee_demographics;

-- when you use group by  you have to have the same columns you're grouping on in the group by statement
SELECT gender
FROM parks_and_recreation.employee_demographics
GROUP BY gender
;
-- group by must match select unless aggregated function
-- SELECT first_name
-- FROM parks_and_recreation.employee_demographics
-- GROUP BY gender
SELECT gender, avg(age)
FROM parks_and_recreation.employee_demographics
GROUP BY gender
;
SELECT occupation
FROM parks_and_recreation.employee_salary
GROUP BY occupation
;
SELECT occupation, salary-- if only salary was 50000 then only one office manager displayed from group by
FROM parks_and_recreation.employee_salary
GROUP BY occupation, salary
;
SELECT gender, MIN(age), MAX(age), COUNT(age), AVG(age)
FROM parks_and_recreation.employee_demographics
GROUP BY gender
;
#We can change that by specifying DESC after it
SELECT *
FROM parks_and_recreation.employee_demographics;

-- if we use order by it goes a to z by default (ascending order)
SELECT *
FROM parks_and_recreation.employee_demographics
ORDER BY first_name;

-- we can manually change the order by saying desc
SELECT *
FROM parks_and_recreation.employee_demographics
ORDER BY first_name DESC;

#Now we can also do multiple columns like this:

SELECT *
FROM parks_and_recreation.employee_demographics
ORDER BY gender, age;

SELECT *
FROM parks_and_recreation.employee_demographics
ORDER BY gender DESC, age DESC;
#now we don't actually have to spell out the column names. We can actually just use their column position

#State is in position 8 and money is in 9, we can use those as well.
-- SELECT *
-- FROM parks_and_recreation.employee_demographics
-- ORDER BY 5 DESC, 4 DESC;

#Now best practice is to use the column names as it's more overt and if columns are added or replaced or something in this table it will still use the right columns to order on.

#So that's all there is to order by - fairly straight forward, but something I use for most queries I use in SQL




