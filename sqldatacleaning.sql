/*

cleaning data in SQL QUERIES

*/

select * 
from PortfolioProject.dbo.NashvilleHousing$

--------------------------------------------------------------

---standardize date format

select SaleDate
from PortfolioProject.dbo.NashvilleHousing$

--we don't need this format of date and time we will convert the date format using CONVERT

select SaleDate, CONVERT(DATE, SaleDate) as Converted_Sale_Date
from PortfolioProject.dbo.NashvilleHousing$

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET SaleDate = CONVERT(DATE, SaleDate)

---update did not work so using  alter table

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-----Checking if it has been updated
select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing$ 

---------------------------------------------------------------------------

---POPULATE PROPERTY ADDRESS DATA
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing$

------we have null values in property address
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing$
where PropertyAddress is null

-----we need to check why it is null
---- we see all the data once again
select *
from PortfolioProject.dbo.NashvilleHousing$
order by ParcelID

---we will use self join on this table to see the ParcelId CONNECTED to the propertyAddress
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing$ a
join PortfolioProject.dbo.NashvilleHousing$ b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----we find there are 35 rows having null property address so we need to populate the b.property address in place of null values
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing$ a
join PortfolioProject.dbo.NashvilleHousing$ b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--so now we need to update the table with this new value
---when using update we need to use alias not the nashville housing else it will give an error

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing$ a
join PortfolioProject.dbo.NashvilleHousing$ b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- we check if its updated by running just the previous select statement once again and yes we didnot get any data...

-------------------------------------------------------------------------
--BREAKING DOWN THE ADDRESS INTO INDIVIDUAL COLUMNS (ADRESS, CITY AND STATE)
----We can see that address has two parts street number and name and city seperated by comma so we will make two column to have them seperately

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing$

-----WE WILL USE SUBSTRING TO DO THAT FOR US

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing$

----now we will update the table with these two new columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

------we will check if the two new columns are added to our table
SELECT *
from PortfolioProject.dbo.NashvilleHousing$

----------------------------------------------------------------------------------------
--Now we will split owner address, we have address, city and state... now we will use PARSENAME which is very useful for stuff delimited by specific value
SELECT OwnerAddress
from PortfolioProject.dbo.NashvilleHousing$

--- for parsename to work we need to replace the comma with a period and it works from the backword index.

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing$

-----NOW UPDATE THE TABLE WITH THESE SPLIT COLUMNS

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

----check if the table is updated

select *
from PortfolioProject.dbo.NashvilleHousing$

---------------------------------------------------------------
--change Y and N to YES AND NO IN SoldAsVacant column

select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing$
group by SoldAsVacant
order by COUNT(SoldAsVacant) desc

------WE WILL USE CASE STATEMENT AND CHANGE Y TO YES AND N TO NO

select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
from PortfolioProject.dbo.NashvilleHousing$

-----UPDATE THE TABLE WITH THIS CASE STATEMENT

UPDATE PortfolioProject.dbo.NashvilleHousing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

	 -------------------------------------------------------------------
--REMOVE DUPLICATES

WITH rownumCTE AS(
select *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelId,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				   UniqueID
				   ) row_num
from PortfolioProject.dbo.NashvilleHousing$
--Order By ParcelID
)
SELECT *
FROM rownumCTE
where row_num > 1
Order by PropertyAddress
------104 rows are duplicates

WITH RowNumCTE AS(
SELECT *,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				     UniqueID
					 ) row_num
FROM PortfolioProject.dbo.NashvilleHousing$
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--Order By PropertyAddress

--------------------------------------------
---DELETE UNSUSED COLUMNS


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing$

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
DROP COLUMN SaleDate