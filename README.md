# Data-Cleaning-in-SQL
Cleaning NashvilleHousing data in SQL

In this project I have used an excelfile data, imported it to SQL and cleaned it , so that it can be more useful.

Skills used: 

A. Standardized date format using CONVERT

B. Populate PropertyAddress into different column based on delimeter, USING SELF JOIN, ISNULL and then used SUBSTRING mainly

c. Populate owners address into different column based on delimeter, used PARSENAME AND REPLACE for this case

D. Normalized the data by changing the distinct values into similar format like Y to Yes and N to No using DISTINCT, COUNT, AND CASE STATEMENTS

E. Removed duplicates using WINDOW FUNCTION - ROW_NUM WITH PARTITION BY USING CTE AND THEN UPDATED THE TABLE

F. Deleted unused column by just dropping the columns using DROP COLUMN

////////////////////////////////////////////////////////////////////////////////

The EXCEL File attached above is the raw data

and the SQL file has the code or query written


I am open for any feedback.

Thank you
