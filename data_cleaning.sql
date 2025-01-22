-- SQL Project - Data Cleaning

-- Kaggle dataset source: https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Step 1: Select raw data from the main layoffs table
SELECT * 
FROM layoffs;

-- Step 2: Create a staging table to work on, ensuring the raw data remains untouched
CREATE TABLE layoffs_staging 
LIKE layoffs; -- Copies the structure of the original table

-- Step 3: Populate the staging table with raw data
INSERT INTO layoffs_staging 
SELECT * FROM layoffs;

select *
from layoffs_staging;
-- Step 4: Outline data cleaning strategy:
-- 1. Identify and remove duplicates
-- 2. Standardize data and fix errors
-- 3. Handle NULL values
-- 4. Remove unnecessary columns or rows

-- 1. Remove Duplicates

-- Check for duplicate rows using ROW_NUMBER
SELECT *
FROM (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
) duplicates
WHERE row_num > 1; -- Rows with row_num > 1 are duplicates

-- Use a Common Table Expression (CTE) to identify duplicates
WITH DUPLICATE_CTE AS 
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM DUPLICATE_CTE
WHERE row_num > 1; -- Display duplicates

-- Example query for identifying duplicate records for a specific company
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Step 5: Create a secondary staging table for cleaning data with row numbers
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- Insert data into the new staging table while calculating row numbers for duplicates
INSERT INTO layoffs_staging_2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

SELECT *
from layoffs_staging_2;
-- Delete duplicate rows (where row_num >= 2)
DELETE FROM layoffs_staging_2
WHERE row_num >= 2;

-- Verify the cleaned table
SELECT *
from layoffs_staging_2;

-- 2. Standardize Data

-- Identify unique values in the 'industry' column
SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY industry;

-- Find rows where 'industry' is NULL or empty
SELECT *
FROM layoffs_staging_2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Example company-specific checks
SELECT *
FROM layoffs_staging_2
WHERE company LIKE 'Bally%'; -- No issues found
SELECT *
FROM layoffs_staging_2
WHERE company LIKE 'airbnb%'; -- Identify missing industry data

-- Replace blank 'industry' values with NULL for consistency
UPDATE layoffs_staging_2
SET industry = NULL
WHERE industry = '';

-- Fill NULL 'industry' values by matching rows with the same company name
UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Standardize variations of 'Crypto' in the 'industry' column
UPDATE layoffs_staging_2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Standardize 'country' values to remove trailing periods
UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country);

-- Convert and standardize the 'date' column to DATE format
UPDATE layoffs_staging_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter the 'date' column type to DATE
ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;

-- 3. Handle NULL Values

-- Example checks for NULL values in key columns
SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete rows where both 'total_laid_off' and 'percentage_laid_off' are NULL
DELETE FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- 4. Remove Unnecessary Columns

-- Drop the 'row_num' column after duplicates are resolved
ALTER TABLE layoffs_staging_2
DROP COLUMN row_num;

-- Final check of the cleaned data
SELECT * 
FROM layoffs_staging_2;
