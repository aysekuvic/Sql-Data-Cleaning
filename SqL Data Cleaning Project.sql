/*

--Cleaning Data in SQL Queries

*/

SELECT *
FROM Portfolio..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format


SELECT SaleDate, CONVERT(date, saledate)
FROM Portfolio..NashvilleHousing

UPDATE Portfolio..NashvilleHousing
SET SaleDate = CONVERT(date, saledate)

ALTER TABLE Portfolio..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Portfolio..NashvilleHousing
SET SaleDateConverted =  CONVERT(date, saledate)

------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT PropertyAddress
FROM Portfolio..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Indivudual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress), LEN(PropertyAddress)) as address
FROM Portfolio..NashvilleHousing

SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as address
FROM Portfolio..NashvilleHousing;




ALTER TABLE Portfolio..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE Portfolio..NashvilleHousing
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE Portfolio..NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE Portfolio..NashvilleHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))




SELECT *
FROM Portfolio..NashvilleHousing

SELECT OwnerAddress
FROM Portfolio..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM Portfolio..NashvilleHousing



ALTER TABLE Portfolio..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Portfolio..NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE Portfolio..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE Portfolio..NashvilleHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE Portfolio..NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE Portfolio..NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



SELECT *
FROM Portfolio..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT distinct(SoldAsVacant)
FROM Portfolio..NashvilleHousing

SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing
GROUP BY SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM Portfolio..NashvilleHousing

UPDATE Portfolio..NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


--------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	            PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	ORDER BY UniqueID) row_num
FROM Portfolio..NashvilleHousing
--ORDER BY ParcelID
)


SELECT *
FROM RowNumCTE
Where row_num >1
Order By PropertyAddress

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	            PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	ORDER BY UniqueID) row_num
FROM Portfolio..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
Where row_num > 1
--Order By PropertyAddress


-----------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, PropertySplitState, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN Saledate



